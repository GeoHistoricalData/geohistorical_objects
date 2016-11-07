EXTENSION    = geohistorical_objects
DATA         = geohistorical_objects--1.0.sql

PG_CONFIG    = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
