
# Geohistorical object#

This postgres extension proposes tools to deal with geohistorical object within postgres.

Geohistorical object are geographic object (geometry) along with historical object (historical name, link to historical source, date).

Using this extension is a simple, clean, efficient and futur proof way to deal with geohistorical objects in database.

## Features
@TODO : add illustration
This extension use postgres inheritance mechanism to simplify your life.

When you need to store geohistorical object, simply create a table that inherits `geohistorical_object.geohistorical_object`,
and register this new table with the function `enable_disable_geohistorical_object(your table name)`


## Dependencies ##

postgres extensions requiered : 
 - Postgis
 - [pgsfti](https://github.com/OnroerendErfgoed/pgSFTI) (postgres extension to deal with fuzzy date)
 - unaccent (default built in postgres)
 
## Install ##
- Copy the two extension files in the postgres extension folder
- Execute the statement `CREATE EXTENSION geohistorical_object;`

## Example of usage :

 You can look in the dedicated example file.
 
 The process to add geohistorical object is always the same :
### Create reference historical source and numerical process. ###

1.1 Any geohistorical object must reference an historical source (historical document,etc.). The source is characterized by a unique short name (meaningfull for you), a complete long name, a thourough description, a fuzzy date (for instance, from 1823 to 1854), and the estimated spatial precision of the information contained in the source (for instance, you can estimate that for a given map of buildings, the buildings are precise up to 10 meters).
 For instance, an historical source could be 
 `'cassini_map_1780', 'the map from the cassini family, published 1780, 2nd edition', '(1821, 1822, 1845, 1846)', '{"default": 5, "building":10}'`
 
 1.2 Any geohistorical object must reference a numeric process through which the historical information was numerized (for instance, somebody looked at the historical source and manually typed the data). 
  This is an essential part of the work: tracking how the data went from being an historical objct to being a computer ressource. Again, the process is characterized by a unique shortname that has a meaning for you, a complete long name, and a thorough description of the process. Again the process happenned in a specific fuzzy period, and can be associated with an estimated precision. For instance, a user created the building footprints by cliking the enveloppe, and can estimate that the points were clicked up to a precision of 3 meters.
  For instance, a numerical process could be 
  `'cassini_manual_edit', 'Using the cassini map, a team of users from university XXX created the data set by manually editing the data', '(2015,2016)', '{"default": 0.2, "building":3}' `

### Create the table you want to use to store geohistorical objects. ###
It can have any columns/ type, you only have to make it inherit `geohistorical_object.geohistorical_object`. Here is an example :

	CREATE TABLE my_cassini_geohistorical_object (
		my_custom_uid serial PRIMARY KEY 
		, my_custom_columns text
		-- etc 
	) INHERITS (geohistorical_object.geohistorical_object) ;
	
### Register the new table ###
3. You have to register the newly created table (only required to do this once). 
	Registering the table is important, it ensures that the link between objects and historical source are enforced, and it also creates indexes that are going to be essential to efficient usages.
	To register the table (only needed once), you use the function 
	
	
	SELECT geohistorical_object.enable_disable_geohistorical_object(  'the_ne_table_schema'::regclass, 'the_new_table_tablename'::regclass, true) ;

### Use your new geohistorical object. ### 
	For instance, adding a new building object related to the previous Cassini map example would be :
	`INSERT INTO my_cassini_geohistorical_object VALUES ('building at angle between rue de la paix and rue du temple',...)`

