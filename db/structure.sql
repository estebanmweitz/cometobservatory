SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: posts_search_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.posts_search_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.searchable_tsearch :=
    SETWEIGHT(to_tsvector('pg_catalog.english', COALESCE(NEW.title, '')), 'A');
  RETURN NEW;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: code_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_lists (
    discord_id character varying NOT NULL,
    public boolean DEFAULT false NOT NULL,
    system_codes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pending_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_posts (
    id bigint NOT NULL,
    source_id bigint NOT NULL,
    post_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pending_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pending_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pending_posts_id_seq OWNED BY public.pending_posts.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    source_id bigint NOT NULL,
    title character varying NOT NULL,
    author character varying,
    summary text,
    url character varying NOT NULL,
    uid character varying NOT NULL,
    published_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    searchable_tsearch tsvector,
    posted_to_discord_at timestamp without time zone,
    posted_to_twitter_at timestamp without time zone
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sources (
    id bigint NOT NULL,
    name character varying NOT NULL,
    url character varying NOT NULL,
    image_filename character varying,
    source_class character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    coverage character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    site_visible boolean DEFAULT true NOT NULL,
    post_to_discord boolean DEFAULT true NOT NULL,
    post_to_twitter boolean DEFAULT true NOT NULL
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.sources.id;


--
-- Name: pending_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_posts ALTER COLUMN id SET DEFAULT nextval('public.pending_posts_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: code_lists code_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_lists
    ADD CONSTRAINT code_lists_pkey PRIMARY KEY (discord_id);


--
-- Name: pending_posts pending_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_posts
    ADD CONSTRAINT pending_posts_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: index_pending_posts_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pending_posts_on_source_id ON public.pending_posts USING btree (source_id);


--
-- Name: index_posts_on_searchable_tsearch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_searchable_tsearch ON public.posts USING gin (searchable_tsearch) WITH (gin_pending_list_limit='128');


--
-- Name: index_posts_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_id ON public.posts USING btree (source_id);


--
-- Name: index_posts_on_uid_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_uid_and_source_id ON public.posts USING btree (uid, source_id);


--
-- Name: posts posts_search_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER posts_search_trigger BEFORE INSERT OR UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.posts_search_trigger();


--
-- Name: pending_posts fk_rails_3c5ece89f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_posts
    ADD CONSTRAINT fk_rails_3c5ece89f8 FOREIGN KEY (source_id) REFERENCES public.sources(id);


--
-- Name: posts fk_rails_d500d7f301; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_d500d7f301 FOREIGN KEY (source_id) REFERENCES public.sources(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210520203238'),
('20210520203424'),
('20210525214054'),
('20210529195638'),
('20210529220308'),
('20210531025322'),
('20210531025415'),
('20210603010314'),
('20210603012316'),
('20210604214329'),
('20210604214428'),
('20210607211127');


