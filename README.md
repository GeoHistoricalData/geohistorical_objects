# Geohistorical objects #

This PostgreSQL extension proposes tools to deal with geohistorical objects within postgres.

Geohistorical objects are geographic object (geometry) along with historical object (historical name, link to historical source, date).

Using this extension is a simple, clean, efficient and future proof way to deal with geohistorical objects in database.

## Features
@TODO : add illustration
This extension uses postgres inheritance mechanism to simplify your life.

When you need to store geohistorical objects, simply create a table that inherits `geohistorical_object.geohistorical_object`,
and register this new table with the function `enable_disable_geohistorical_object(your table name)`.

## Dependencies ##
First, you obviously need [PostgreSQL](https://www.postgresql.org/) installed. For now, we only tested with versions 9.5 and 9.6.
[PostgreSQL](https://www.postgresql.org/) extensions required:
 - [Postgis](http://postgis.net/)
 - [pgsfti](https://github.com/OnroerendErfgoed/pgSFTI) (postgres extension to deal with fuzzy date)
 - unaccent (default built in postgres)
 
## Install ##
- Get the extension and copy the two extension files in the postgres extension folder:
~~~~
git clone https://github.com/GeoHistoricalData/geohistorical_objects
cd geohistorical_objects
sudo make install
~~~~
- Install the necessary extensions:
~~~~
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgsfti;
~~~~
- Install the extension:
~~~~
CREATE EXTENSION geohistorical_objects;
~~~~

## Example of usage:

You can look in the dedicated example file.
 
The process to add geohistorical object is always the same:

### Create reference historical source and numerical process. ###

Any geohistorical object must reference an historical source (historical document,etc.). The source is characterized by a unique short name (meaningfull for you), a complete long name, a thourough description, a fuzzy date (for instance, from 1823 to 1854), and the estimated spatial precision of the information contained in the source (for instance, you can estimate that for a given map of buildings, the buildings are precise up to 10 meters).
Note that the spatial precision information is given via a json that _must_ contain a `default` spatial precision.


For instance, an historical source could be 
 ~~~~
 INSERT INTO geohistorical_object.historical_source VALUES (
     'cassini_map_1780',
     'the map from the cassini family, published 1780, 2nd edition',
     '(wiki) In France, the first general maps of the territory using a measuring apparatus were made by the Cassini family during the 18th century on a scale of 1:86,400 (one centimeter on the chart corresponds to approximately 864 meters on the ground). These maps were, for their time, a technical innovation ',
     '(1821, 1822, 1845, 1846)', 
     '{"default": 5, "building":10}'); 
 ~~~~
 
Any geohistorical object must reference a numeric process through which the historical information was numerized (for instance, somebody looked at the historical source and manually typed the data). 
  This is an essential part of the work: tracking how the data went from being an historical objct to being a computer ressource. 
  
  Again, the process is characterized by a unique shortname that has a meaning for you, a complete long name, and a thorough description of the process. 
  Again the process happenned in a specific fuzzy period, and can be associated with an estimated precision. For instance, a user created the building footprints by cliking the enveloppe, and can estimate that the points were clicked up to a precision of 3 meters.
  Again, a `default` spatial precision _must_ be indicated.
  
  
  For instance, a numerical process could be 
  ~~~~
  INSERT INTO numerical_origin_process VALUES (
      'cassini_manual_edit_team_EHESS',
      'Using the cassini map, a team of users from EHESS university created the data set by manually editing the data using the v2 map',
      'The precise numerising process : the map were georeferenced using ground points, then the spatial referencing was performed with QGIS using ... . The edit was done at scale between ... and ... . People were asked to edit XXX features, and make XXX choices. Some uncertainity were encountered regarding XXX, which were solved by doing XXX. We estimat the data to be good quality. We estimate the coverage to be almost complete (>99%). We think this process leaves XXX to be edited...',
      '(2015,2016)', 
      '{"default": 0.2, "building":3}' );
  ~~~~
  
  
### Create the table you want to use to store geohistorical objects. ###
It can have any columns / type, you only have to make it inherit `geohistorical_object.geohistorical_object`.
Here is an example:
~~~~
CREATE TABLE my_cassini_geohistorical_object (
	my_custom_uid serial PRIMARY KEY 
	, my_custom_columns text
	-- etc 
) INHERITS (geohistorical_object.geohistorical_object) ;
~~~~
	
### Register the new table ###
You have to register the newly created table (only required to do this once). 
Registering the table is important, it ensures that the link between objects and historical source are enforced, and it also creates indexes that are going to be essential to efficient usages.
To register the table (only needed once), you use the function:
~~~~	
SELECT geohistorical_object.register_geohistorical_object_table(  'the_ne_table_schema', 'the_new_table_tablename') ;
~~~~

### Use your new geohistorical object. ### 
For instance, adding a new building object related to the previous Cassini map example would be:
~~~~	
INSERT INTO my_cassini_geohistorical_object VALUES ('building at angle between rue de la paix and rue du temple',...)
~~~~	

