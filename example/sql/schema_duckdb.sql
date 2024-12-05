create table post
(
    id        text primary key,
    parent_id text         not null,
    content   text not null,
    star      integer
);


CREATE TABLE array_and_json
(
    name             text,
    int_array        integer[],
    text_array_array text[][],
    json_data        json
);
