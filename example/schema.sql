DROP DOMAIN IF EXISTS post_content CASCADE;
CREATE DOMAIN post_content TEXT
    CONSTRAINT post_content CHECK (
        VALUE != ''
    );

create table post
(
    id        text primary key,
    parent_id text         not null,
    content   post_content not null,
    star integer
);


