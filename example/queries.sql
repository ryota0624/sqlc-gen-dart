-- name: getReplyIds :many
select id
from post
where parent_id = $1;

-- name: getPost :one
select id, parent_id, content
from post
where id = $1;

-- name: listPosts :many
select *
from post;

-- name: createPost :exec
insert into post (id, parent_id, content, star)
values ($1, $2, $3, $4)
returning *;
