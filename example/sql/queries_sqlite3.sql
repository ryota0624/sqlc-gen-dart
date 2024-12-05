-- name: getReplyIds :many
select id
from post
where parent_id = ?;

-- name: getPost :one
select id, parent_id, content
from post
where id = ?;

-- name: listPosts :many
select *
from post;

-- name: createPost :exec
insert into post (id, parent_id, content, star)
values (?, ?, ?, ?)
returning *;

-- name: listArrayAndJson :many
select *
from array_and_json;
