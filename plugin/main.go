package main

import (
	_ "embed"

	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"text/template"

	"github.com/sqlc-dev/plugin-sdk-go/codegen"
	"github.com/sqlc-dev/plugin-sdk-go/plugin"
)
import "github.com/golang-cz/textcase"

//go:embed template/domain_types_template.go.tmpl
var domainTypesTemplateContent []byte

//go:embed template/query_template.go.tmpl
var queryTemplateContent []byte

func main() {
	codegen.Run(generate)
}

type Options struct {
	Template               string `json:"template" yaml:"template"`
	Filename               string `json:"filename" yaml:"filename"`
	DomainTypesTemplate    string `json:"domain_types_template" yaml:"domain_types_template"`
	DomainInnerTypeMapping []struct {
		TypeName  string `json:"type_name" yaml:"type_name"`
		InnerType string `json:"inner_type" yaml:"inner_type"`
	} `json:"domain_inner_type_mapping" yaml:"domain_inner_type_mapping"`
	Out string `json:"out" yaml:"out"`
}

func parseOpts(req *plugin.GenerateRequest) (*Options, error) {
	var options Options
	if len(req.PluginOptions) == 0 {
		return &options, nil
	}
	if err := json.Unmarshal(req.PluginOptions, &options); err != nil {
		return nil, fmt.Errorf("unmarshalling plugin options: %w", err)
	}

	return &options, nil
}

type QueryTemplateParams struct {
	*plugin.GenerateRequest
	DomainTypesDartFilePath string
}

const domainTypesDartFileName = "domain_types.dart"

type DomainType struct {
	InnerType  string
	Name       string
	OnPsqlName string
}

func generate(_ context.Context, req *plugin.GenerateRequest) (*plugin.GenerateResponse, error) {
	options, err := parseOpts(req)
	if err != nil {
		return nil, fmt.Errorf("parsing options: %w", err)
	}

	domainTypes := NewDomainTypes()
	for _, domainType := range options.DomainInnerTypeMapping {
		domainTypes.AddType(DomainType{
			Name:       textcase.PascalCase(domainType.TypeName),
			InnerType:  domainType.InnerType,
			OnPsqlName: domainType.TypeName,
		})
	}

	queryTmpl := template.Must(template.New("query_template.go.tmpl").Funcs(map[string]any{
		"IsDomainTypeColumn": func(column *plugin.Column) bool {
			_, ok := domainTypes.GetDomainType(column.Type.Name)
			return ok
		},
		"DartType": func(column *plugin.Column) string {
			return dartType(column, domainTypes)
		},
		"EvalQueryResultInput": EvalQueryResultInput,
		"ToCamelCase":          textcase.CamelCase,
		"ToPascalCase":         textcase.PascalCase,
		"EscapeQueryPlaceholder": func(text string) string {
			return strings.ReplaceAll(text, "$", "\\$")
		},
	}).Parse(string(queryTemplateContent)))

	domainTypesTmpl := template.Must(template.New("domain_types_template.go.tmpl").Parse(string(domainTypesTemplateContent)))
	resp := plugin.GenerateResponse{}

	var domainTypesCodeBuf bytes.Buffer
	err = domainTypesTmpl.Execute(&domainTypesCodeBuf, struct {
		DomainTypes []DomainType
	}{
		DomainTypes: domainTypes.GetTypesSlice(),
	})

	var queryCodeBuf bytes.Buffer
	err = queryTmpl.Execute(&queryCodeBuf, QueryTemplateParams{
		GenerateRequest:         req,
		DomainTypesDartFilePath: "./" + domainTypesDartFileName,
	})
	if err != nil {
		log.Fatalf("Error executing template: %v", err)
	}

	resp.Files = append(resp.Files, &plugin.File{
		Name:     domainTypesDartFileName,
		Contents: domainTypesCodeBuf.Bytes(),
	})

	resp.Files = append(resp.Files, &plugin.File{
		Name:     options.Filename,
		Contents: queryCodeBuf.Bytes(),
	})

	return &resp, nil
}

type DomainTypes struct {
	TypesMapByOnPsqlName map[string]DomainType
}

func NewDomainTypes() *DomainTypes {
	return &DomainTypes{
		TypesMapByOnPsqlName: make(map[string]DomainType),
	}
}

func (d *DomainTypes) AddType(domainType DomainType) {
	d.TypesMapByOnPsqlName[domainType.OnPsqlName] = domainType
}

func (d *DomainTypes) GetDomainType(onPsqlName string) (DomainType, bool) {
	domainType, ok := d.TypesMapByOnPsqlName[onPsqlName]
	return domainType, ok
}

func (d *DomainTypes) GetTypesSlice() []DomainType {
	var domainTypes []DomainType
	for _, domainType := range d.TypesMapByOnPsqlName {
		domainTypes = append(domainTypes, domainType)
	}
	return domainTypes
}

func dartType(column *plugin.Column, types *DomainTypes) string {
	if domainType, ok := types.GetDomainType(column.Type.Name); ok {
		return domainType.Name
	}
	switch column.Type.Name {
	case "integer":
		return "int"
	case "text":
		return "String"
	default:
		return "Object"
	}
}

type QueryResult struct {
	Columns            []*plugin.Column
	Cmd                string
	FunctionReturnType string
	RowType            string
}

func QueryResultRowType(query plugin.Query) string {
	pascalCaseName := textcase.PascalCase(query.Name)
	return fmt.Sprintf("Row%s", pascalCaseName)
}

func EvalQueryResultInput(query plugin.Query) *QueryResult {
	var functionReturnType string
	rowType := QueryResultRowType(query)
	switch query.Cmd {
	case ":exec":
		functionReturnType = "void"
	case ":many":
		functionReturnType = fmt.Sprintf("List<%s>", rowType)
	case ":one":
		functionReturnType = fmt.Sprintf("%s?", rowType)
	default:
		panic(fmt.Sprintf("Unsupported query command: %s", query.Cmd))
	}

	return &QueryResult{
		Columns:            query.Columns,
		Cmd:                query.Cmd,
		FunctionReturnType: functionReturnType,
		RowType:            rowType,
	}
}
