	CREATE USER wnkd PASSWORD 'EXAMPLE#!';
	CREATE DATABASE wnkd;

\connect wnkd

BEGIN;
	CREATE EXTENSION "uuid-ossp";
	CREATE EXTENSION "citext";
	CREATE TYPE item_category AS ENUM (
		'material',
		'function',
		'design',
		'original'
	);

	CREATE TABLE item (
		id SERIAL PRIMARY KEY,
		active boolean default 't',
		name TEXT,
		category item_category NOT NULL,
		short_description TEXT,
		full_description TEXT,
		uuid citext NOT NULL DEFAULT uuid_generate_v4()
	);
	GRANT SELECT, UPDATE, INSERT ON TABLE item TO wnkd;
	GRANT USAGE, SELECT ON SEQUENCE item_id_seq TO wnkd;

	CREATE TABLE tag (
		id SERIAL PRIMARY KEY,
		label TEXT NOT NULL UNIQUE
	);
	GRANT SELECT, UPDATE, INSERT ON TABLE tag TO wnkd;
	GRANT USAGE, SELECT ON SEQUENCE tag_id_seq TO wnkd;

	CREATE TABLE item_tag (
		id serial primary key,
		item integer references item(id),
		tag  integer references tag(id),
		unique(item, tag)
	);
	GRANT SELECT, UPDATE, INSERT ON TABLE item_tag TO wnkd;
	GRANT USAGE, SELECT ON SEQUENCE item_tag_id_seq TO wnkd;

	CREATE TYPE photo_role as enum(
		'fullsize', 'thumbnail'
	);

	CREATE TYPE photo_type as enum(
		'png', 'jpg'
	);

	CREATE TABLE photo (
		id SERIAL PRIMARY KEY,
		featured BOOLEAN NOT NULL DEFAULT 'f',
		item INTEGER REFERENCES item(id),
		type photo_type NOT NULL,
		role photo_role NOT NULL,
		uuid citext NOT NULL DEFAULT uuid_generate_v4()
	);
	GRANT SELECT, UPDATE, INSERT ON TABLE photo TO wnkd;
	GRANT USAGE, SELECT ON SEQUENCE photo_id_seq TO wnkd;
COMMIT;
