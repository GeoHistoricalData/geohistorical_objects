--------------------
-- Remi Cura, 2016 , Projet Belle Epoque
-- Geohistorical data project
--------------------

-- script to create postgres extension relativ to dealing with geohistorical objects

-- dependencies 
-- CREATE EXTENSION IF NOT EXISTS pgsfti ; 
-- CREATE EXTENSION IF NOT EXISTS unaccent;

--create the main schema
CREATE SCHEMA IF NOT EXISTS geohistorical_object ; 

--------------------
--- Adding helper functions
--------------------

DROP FUNCTION IF EXISTS geohistorical_object.is_valid_source_json(   IN ijson json ) CASCADE; 
CREATE OR REPLACE FUNCTION geohistorical_object.is_valid_source_json(    IN ijson json )
RETURNS boolean AS 
	$BODY$
		--@brief : this function takes the json of a geohistorical source / origin and check that it contains the defaukt value
		-- @example : example of correct json : SELECT '{"default": 0.2, "road":2.5, "building":0.9}'::json
		DECLARE     
			is_valid_1 boolean := FALSE ; 
			def_value float := NULL; 
		BEGIN 
			is_valid_1 :=  ijson -> 'default' IS NOT NULL;  
			IF is_valid_1 = true THEN
				def_value := ijson #>> '{"default"}' ;
				IF def_value IS NOT NULL AND def_value >= 0 THEN RETURN true;  END IF ; 
			END IF ;  
		RETURN FALSE;
		END ; 
	$BODY$
LANGUAGE plpgsql  IMMUTABLE STRICT; 

SELECT geohistorical_object.is_valid_source_json(f1), geohistorical_object.is_valid_source_json(f2) 
FROM CAST ( '{"default": 0.2, "road_axis":2.5, "building":0.9}' AS json )  as f1
	, CAST ( '{ "road_axis":2.5, "building":0.9}' AS json )  as f2 ;
	
	
---------------------
-- template for sources and origin
--------------------- 

DROP TABLE IF EXISTS geohistorical_object.source_object_template CASCADE ; 
CREATE TABLE IF NOT EXISTS geohistorical_object.source_object_template (
 short_name text UNIQUE NOT NULL--this is a short name uniquely describing the source
, full_name text NOT NULL -- this mandatory full name is a more human friendly name, and should be a few words max
, description text NOT NULL -- this mandatory description is the details of the source, and sould be a few sentences at least
, default_fuzzy_date sfti NOT NULL -- this fuzzy date is the defautl one for all the object associated
, default_spatial_precision json NOT NULL CHECK( geohistorical_object.is_valid_source_json(default_spatial_precision) = TRUE) --this json is a dictionnary with a defined structure. Each potential object type is given a spatial precision. The value 'default' is mandatory as a default value for all kind of objects.
); 
------ note of design 
-- primary key and unique are redundant, but necessayr in the inheritance case
-- all fields are mandatory to prevent novice user to break database
-- default for json is the value that must always be present


DROP TABLE IF EXISTS geohistorical_object.historical_source; 
CREATE TABLE IF NOT EXISTS geohistorical_object.historical_source( 
UNIQUE (short_name)
) INHERITS (geohistorical_object.source_object_template)  ;
ALTER TABLE geohistorical_object.historical_source ADD PRIMARY KEY (short_name) ; 
-- some precisions : 
-- fuzzy date : an historical source is an interpretation of the real world at a given period. The default fuzzy date represent this period.
	-- for instance, a copy (1879) of the original map (printing 1856) where the information was acquired between 1850 and 1854 should have a fuzzy date of 1850-1854.
-- default spatial precision represents the overal spatial precision for this source and this object  
	--for instance, a map representing the position of buildings may suffer from various spatial errors: because of the scale, building may be un precise, manual computing error, topographical error, etc. The default_spatial_precision for this building is the overall spatial error.
	-- i.e. How much would I need to buffer the geometry to be sure (p>0.99) that the real building is contained by this buffered geometry .
 


DROP TABLE IF EXISTS geohistorical_object.numerical_origin_process CASCADE; 
CREATE TABLE IF NOT EXISTS geohistorical_object.numerical_origin_process( 
UNIQUE (short_name)
) INHERITS (geohistorical_object.source_object_template)  ;
ALTER TABLE geohistorical_object.numerical_origin_process ADD PRIMARY KEY (short_name) ; 
-- some precisions : 
-- fuzzy date : this table represent the process of transforming a real worl historical source into numeric data.
	-- the date is then the date of this process ! 
	-- for instance, a copy (1879) of the original map (printing 1856) where the information was acquired between 1850 and 1854 should have a fuzzy date of 1850-1854.
-- default spatial precision represents the overal spatial precision for this source and this object  
	--for instance, a map representing the position of buildings may suffer from various spatial errors: because of the scale, building may be un precise, manual computing error, topographical error, etc. The default_spatial_precision for this building is the overall spatial error.
	-- i.e. How much would I need to buffer the geometry to be sure (p>0.99) that the real building is contained by this buffered geometry .

 
-- DONT PUT ANYTHING IN THIS  TABLE, USE INHERITANCE (see test section for an example)
DROP TABLE IF EXISTS geohistorical_object.geohistorical_object CASCADE ; 
CREATE TABLE IF NOT EXISTS geohistorical_object.geohistorical_object (
	historical_name text,  -- the complete historical name, including strange characters, mistake of spelling, etc. This should not be used for joining and so, only for historical analysis
	normalised_name text, -- a normalised version of the name , sanitized. This version may be used for joins and so
	geom geometry, -- all geometry should be in the same srid
	specific_fuzzy_date sfti, -- OPTIONNAL : if defined, overrides the defaut fuzzy dates of the historical source
	specific_spatial_precision float, -- OPTIONNAL : if defined, ovverides the defaut spatial precision
	historical_source text REFERENCES geohistorical_object.historical_source ( short_name) NOT NULL, -- link to the historical source, mandatory
	numerical_origin_process text REFERENCES geohistorical_object.numerical_origin_process (  short_name) NOT NULL, -- link to the origin process, mandatory
	 UNIQUE (normalised_name, geom) --adding a constraint to limit duplicates (obvious errors here) 
	 , check (false) NO INHERIT
); 


-- This table contains the list of relations
DROP TABLE IF EXISTS geohistorical_object.geohistorical_relations_references CASCADE; 
CREATE TABLE IF NOT EXISTS geohistorical_object.geohistorical_relations_references (
	 short_name text PRIMARY KEY--this is a short name uniquely describing the source
	, full_name text NOT NULL -- this mandatory full name is a more human friendly name, and should be a few words max
	, description text NOT NULL   
	, relation_values json -- here the user can put any value type needed
); 
 

-- DONT PUT ANYTHING IN THIS  TABLE, USE INHERITANCE (see test section for an example)
DROP TABLE IF EXISTS geohistorical_object.geohistorical_relation CASCADE; 
CREATE TABLE IF NOT EXISTS geohistorical_object.geohistorical_relation(
	short_historical_source_name_1 text REFERENCES geohistorical_object.historical_source (short_name)
	, normalised_name_1 text NOT NULL  
	, geom_1 geometry
	, short_historical_source_name_2 text REFERENCES geohistorical_object.historical_source (short_name)
	, normalised_name_2 text  
	, geom_2 geometry
	, relation_name text REFERENCES geohistorical_object.geohistorical_relations_references (short_name)
	, UNIQUE (short_historical_source_name_1, normalised_name_1, geom_1
		  ,short_historical_source_name_2, normalised_name_2,geom_2) -- this constraint ensure that the same equivalence is not defined several times 
	 , check (false) NO INHERIT
);  
CREATE INDEX ON geohistorical_object.geohistorical_relation (short_historical_source_name_1) ; 
CREATE INDEX ON geohistorical_object.geohistorical_relation (short_historical_source_name_2) ; 
CREATE INDEX ON geohistorical_object.geohistorical_relation (normalised_name_1) ; 
CREATE INDEX ON geohistorical_object.geohistorical_relation (normalised_name_2) ; 
CREATE INDEX ON geohistorical_object.geohistorical_relation (geom_1) ; 
CREATE INDEX ON geohistorical_object.geohistorical_relation (geom_2) ;
CREATE INDEX ON geohistorical_object.geohistorical_relation (relation_name) ;
 
 
 -------------------------------
 -- Functions 
 -------------------------------
 
 
 
DROP FUNCTION IF EXISTS geohistorical_object.json_spatial_precision(   IN ijson json, IN specific_field_name text ); 
CREATE OR REPLACE FUNCTION geohistorical_object.json_spatial_precision(    IN ijson json , IN specific_field_name text)
RETURNS float AS 
	$BODY$
		--@brief : this function takes the json of a geohistorical source / numerical process, and extract the spatial precision
		-- @example : example '{"default": 0.2, "road":2.5, "building":0.9}'::json : 0.9 for building !
		DECLARE       
		BEGIN  
			RETURN COALESCE(ijson ->> quote_ident(specific_field_name), ijson->>'default') ;
		 
		END ; 
	$BODY$ 
LANGUAGE plpgsql  IMMUTABLE STRICT; 


SELECT geohistorical_object.json_spatial_precision(  ex , 'building'::text)
FROM CAST ('{"default": 0.2, "road":2.5, "building":0.9}' AS json) AS ex ; 



DROP FUNCTION IF EXISTS geohistorical_object.find_all_children_in_inheritance(   IN parent_table_full_name regclass); 
CREATE OR REPLACE FUNCTION geohistorical_object.find_all_children_in_inheritance(   IN parent_table_full_name regclass)
RETURNS table(children_table text) AS 
	$BODY$
		--@brief : given a parent table, look for all the tables that inherit from it (several level of inheritance allowed)
		DECLARE      
		BEGIN 
		 RETURN QUERY 
			SELECT children::text FROM (
				   WITH RECURSIVE inh AS (
					SELECT i.inhrelid FROM pg_catalog.pg_inherits i WHERE inhparent = parent_table_full_name::regclass
					UNION
					SELECT i.inhrelid FROM inh INNER JOIN pg_catalog.pg_inherits i ON (inh.inhrelid = i.inhparent)
				)
				SELECT pg_namespace.nspname AS father , pg_class.relname  AS children
				    FROM inh 
				      INNER JOIN pg_catalog.pg_class ON (inh.inhrelid = pg_class.oid) 
				      INNER JOIN pg_catalog.pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
		      ) AS sub;

		RETURN ;
		END ; 
	$BODY$
LANGUAGE plpgsql  IMMUTABLE STRICT; 



DROP FUNCTION IF EXISTS geohistorical_object.find_foreign_key_between_source_and_target(   source_schema text, source_table text, source_column text,
	target_schema text, target_table text, target_column text); 
CREATE OR REPLACE FUNCTION geohistorical_object.find_foreign_key_between_source_and_target(   source_schema text, source_table text, source_column text,
	target_schema text, target_table text, target_column text)
RETURNS table(constraint_catalog text, constraint_schema text, constraint_name text) AS 
	$BODY$
		--@brief : given a source and target table and columns, returns the foreign keys if it exists
		DECLARE      
		BEGIN 
			-- conver
			RETURN QUERY 

			SELECT tc.constraint_catalog::text , tc.constraint_schema::text  , tc.constraint_name::text
			FROM information_schema.table_constraints tc 
			INNER JOIN information_schema.constraint_column_usage ccu 
			  USING (constraint_catalog, constraint_schema, constraint_name) 
			INNER JOIN information_schema.key_column_usage kcu 
			  USING (constraint_catalog, constraint_schema, constraint_name) 
			WHERE constraint_type = 'FOREIGN KEY' 
			  AND tc.table_schema = source_schema
			  AND tc.table_name = source_table
			  AND kcu.column_name = source_column
			    AND ccu.table_schema = target_schema
			    AND ccu.table_name = target_table
			    AND ccu.column_name = target_column; 
		RETURN ;
		END ; 
	$BODY$
LANGUAGE plpgsql  IMMUTABLE STRICT; 

-- SELECT *
-- FROM geohistorical_object.find_foreign_key_between_source_and_target(  'geohistorical_object', 'test_geohistorical_object', 'historical_source','geohistorical_object', 'historical_source', 'short_name' ) ; 



DROP FUNCTION IF EXISTS geohistorical_object.register_geohistorical_object_table(schema_name text, table_name text); 
CREATE OR REPLACE FUNCTION geohistorical_object.register_geohistorical_object_table(schema_name text, table_name text)
RETURNS text AS 
	$BODY$
		--@brief : this function takes a table name, check if it inherits from geohistorical_object or normalised_name_alias. If activate is true, add foregin key, else remove it 
		DECLARE  
			_isobj record; 
			_isrelation record; 
			_isobjb boolean;
			_isrelationb boolean ;  
			_sql text ; 
		BEGIN 
			-- get schema and table name from input
			
			-- check if input table is in the list of tables that inherits from 'geohistorical_object' and/or from 'normalised_name_alias' 
				SELECT children_table INTO _isobj
				FROM  geohistorical_object.find_all_children_in_inheritance('geohistorical_object.geohistorical_object')
				WHERE children_table = table_name::text
				LIMIT 1 ;
				SELECT children_table INTO _isrelation
				FROM  geohistorical_object.find_all_children_in_inheritance('geohistorical_object.geohistorical_relation')
				WHERE children_table = table_name::text
				LIMIT 1 ;

				_isobjb := _isobj IS NOT NULL; 
				_isrelationb := _isrelation IS NOT NULL;  

				RAISE NOTICE 'is this table heriting from "geohistorical_object" : % ; Is this table inheriting from "normalised_name_alias" % ' ,_isobjb,_isrelationb ; 

				
			IF _isobjb IS TRUE THEN 
			-- case when we inherit from geohistorical_object.geohistorical_object
				-- 2 foreign key to add + 6 indexes to create 
				
				_sql := format('
				ALTER TABLE %1$s.%2$s ADD CONSTRAINT historical_source_short_name FOREIGN KEY (historical_source)
				REFERENCES geohistorical_object.historical_source (short_name) ; 
				ALTER TABLE %1$s.%2$s ADD CONSTRAINT numerical_origin_process_short_name FOREIGN KEY (numerical_origin_process)
				REFERENCES geohistorical_object.numerical_origin_process (short_name); ',schema_name, table_name );
				--raise notice 'ploup' ; 
				BEGIN
				    EXECUTE _sql ; 
				EXCEPTION
				    WHEN others  THEN
					 raise notice '% %', SQLERRM, SQLSTATE;
					RETURN 'error : this table is already registered, you only need to do it once' ; 
				END;

				_sql := format('
				CREATE INDEX %1$s_%2$s_numerical_origin_process_idx
				ON %1$s.%2$s USING btree (numerical_origin_process);
				CREATE INDEX %1$s_%2$s_historical_source_idx
				ON %1$s.%2$s USING btree (historical_source);
				CREATE INDEX %1$s_%2$s_normalised_name_idx
				ON %1$s.%2$s USING gin (normalised_name gin_trgm_ops);
				CREATE INDEX %1$s_%2$s_historical_name_idx
				ON %1$s.%2$s USING gin (historical_name gin_trgm_ops);
				CREATE INDEX %1$s_%2$s_geom_idx
				ON %1$s.%2$s  USING gist (geom);
				CREATE INDEX %1$s_%2$s_specific_fuzzy_date_idx
				ON %1$s.%2$s USING gist ((specific_fuzzy_date::geometry));
				',schema_name, table_name) ; 

				EXECUTE _sql ;
			END IF ; -- case of inheriting geohistorical_object.geohistorical_object
				 
			IF _isrelationb IS TRUE THEN -- case when we inherit from geohistorical_object.normalised_name_alias, we have potentially  foreign key to add /delete
				_sql := format('
				ALTER TABLE %1$s.%2$s
				ADD CONSTRAINT %1$s_%2$s_relation_name_fkey FOREIGN KEY (relation_name)
				REFERENCES geohistorical_object.geohistorical_relations_references (short_name) ;

				ALTER TABLE %1$s.%2$s
				ADD CONSTRAINT %1$s_%2$s_short_historical_source_name_1_fkey FOREIGN KEY (short_historical_source_name_1)
				REFERENCES geohistorical_object.historical_source (short_name) ;

				ALTER TABLE %1$s.%2$s 
				ADD CONSTRAINT %1$s_%2$s_short_historical_source_name_2_fkey FOREIGN KEY (short_historical_source_name_2)
				REFERENCES geohistorical_object.historical_source (short_name) ;
				',schema_name, table_name);

				BEGIN
				    EXECUTE _sql ; 
				EXCEPTION
				    WHEN others  THEN
					 raise notice '% %', SQLERRM, SQLSTATE;
					RETURN 'error : this table is already registered, you only need to do it once' ; 
				END;

				_sql := format(' 
				CREATE INDEX %1$s_%2$s_geom_1_idx
				ON %1$s.%2$s USING btree(geom_1);

				CREATE INDEX %1$s_%2$s_geom_2_idx
				ON %1$s.%2$s USING btree(geom_2);

				CREATE INDEX %1$s_%2$s_normalised_name_1_idx
				ON %1$s.%2$s USING btree(normalised_name_1); 

				CREATE INDEX %1$s_%2$s_normalised_name_2_idx
				ON %1$s.%2$s USING btree(normalised_name_2); 

				CREATE INDEX %1$s_%2$s_relation_name_idx
				ON %1$s.%2$s USING btree (relation_name); 

				CREATE INDEX %1$s_%2$s_short_historical_source_name_1_idx
				ON %1$s.%2$s USING btree (short_historical_source_name_1);

				CREATE INDEX %1$s_%2$s_short_historical_source_name_2_idx
				ON %1$s.%2$s USING btree (short_historical_source_name_2);
				', schema_name, table_name); 

			EXECUTE _sql ; 

			END IF ; -- case of inheriting geohistorical_object.geohistorical_object


		RETURN format('table registered. This table was inheriting from geohistorical_object (%s), from geohistorical_relation (%s)! foreign key + index creation OK', _isobjb,_isrelationb);
		END ; 
	$BODY$
LANGUAGE plpgsql  VOLATILE STRICT; 
 
 
	DROP FUNCTION IF EXISTS geohistorical_object.clean_text(   it text ); 
		CREATE OR REPLACE FUNCTION geohistorical_object.clean_text(  it text )
		RETURNS text AS 
			$BODY$
				--@brief : this function takes a string and return it cleaned 
				DECLARE      
				BEGIN 
					RETURN 
					regexp_replace( 
						regexp_replace( 
							regexp_replace(
								regexp_replace(  
									lower( --all to small font
										unaccent(it) --removing accent
									)
								, '[^a-zA-Z0-9]+', ' ', 'g') --removing characters that are not letters or digits
							, '[_]+', ' ', 'g') --removing underscore
						, '\s+$', '') --removing things lliek space at  the end
					 ,'^\s+', '') --removing things like space at the beginning
					 ;
				END ; 
			$BODY$
		LANGUAGE plpgsql  IMMUTABLE STRICT;  
		--SELECT geohistorical_object.clean_text(  $$  5zer'ezer_ze ze'r $*ùzer ;   $$);

