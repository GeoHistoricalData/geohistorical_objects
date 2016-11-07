------------------------
-- Remi Cura, 2016 , Projet Belle Epoque
-- Geohistorical data project
------------------------



SELECT geohistorical_object.is_valid_source_json(f1), geohistorical_object.is_valid_source_json(f2) 
FROM CAST ( '{"default": 0.2, "road_axis":2.5, "building":0.9}' AS json )  as f1
	, CAST ( '{ "road_axis":2.5, "building":0.9}' AS json )  as f2 ;

	 
-------------------------
-- TESTING ! 
------------------------

-- creating test values :

--geohistorical_object.historical_source ;
CREATE EXTENSION IF NOT EXISTS pgsfti ; 
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm ; 

DROP EXTENSION IF EXISTS geohistorical_objects CASCADE ; 
CREATE EXTENSION geohistorical_objects ; 


SELECT *
FROM geohistorical_object.geohistorical_object  ;



SELECT geohistorical_object.is_valid_source_json(f1), geohistorical_object.is_valid_source_json(f2) 
FROM CAST ( '{"default": 0.2, "road_axis":2.5, "building":0.9}' AS json )  as f1
	, CAST ( '{ "road_axis":2.5, "building":0.9}' AS json )  as f2 ;






SELECT *
FROM geohistorical_object.historical_source ;

TRUNCATE geohistorical_object.historical_source  CASCADE ; 
INSERT INTO geohistorical_object.historical_source VALUES 
	('jacoubet_paris'
	, 'Atlas Général de la Ville, des faubourgs et des monuments de Paris, Simon-Théodore Jacoubet'
	, 'Simon-Théodore Jacoubet, né en 1798 à Toulouse fut architecte employé dès
1823 à la Préfecture de la Seine puis chef du bureau chargé de la réalisation des
plans d’alignements. Mêlé à divers procès liés à ses activités à la préfecture, il fut
révolutionnaire en 1830, 1832 puis 1848, arrêté, interné et condamné à la déportation
en Algérie en 1852, condamné à la mort civile et enfin assigné à résidence à
Montesquieu-Volvestre la même année. Il sera l’auteur du plus grand et plus complet
plan de Paris existant sur la première moitié du XIXe siècle.
La réalisation de son Atlas Général de la Ville, des faubourgs et des monuments
de Paris est une fenêtre ouverte non seulement sur la topographie parisienne préhaussmanienne,
mais aussi sur le fonctionnement des services de voirie de la Seine.
13. En 1851 encore, les plans de percements de la rue de Rivoli entre la rue de la Bibliothèque et la rue
du Louvre seront tracés sur un plan parcellaire très proche de celui de Vasserot 

Suivre la construction de cet atlas permet non seulement d’entrer au coeur de la
machine d’aménagement urbain mise en place en 1800 par Napoléon, mais surtout
de découvrir les rapports qu’entretenaient les employés de la préfecture et les agents
d’affaires dans un objectif commun de spéculations immobilières, ainsi que la corruption
à l’oeuvre dans les services chargés de l’aménagement urbain : percements,
alignements, gestion des carrières, etc. 
2.4.1 Levé et structure du plan
Le travail de Jacoubet s’inscrit volontairement dans la lignée des grands plans
de Paris contruits au XVIIIe siècle 14. Commencé entre 1825 et 1827, l’Atlas Général
s’inspire directement des travaux de Verniquet dont il reprend en partie la
triangulation. Il est important de noter dès maintenant que Jacoubet entreprend
la réalisation de son atlas alors qu’il se trouve employé au Bureau des Plans de la
préfecture de la Seine. C’est grâce à cette position qu’il sera en mesure d’utiliser
les relevés topographiques réalisés par les géomètres de l’administration à partir des
plans de Verniquet, alors utilisé comme plan général pour les travaux de voierie.
Comme nous le verrons plus tard, il a également repris les mesures de triangulation
effectuées par les équipes de Verniquet, ce qui lui permet d’économiser des opérations
de levé topographiques d’envergure 15. L’atlas est réalisé entre 1825 (ou 1827)
et 1836 et il est publié par parties selon la méthode de la souscription. Cette méthode
consiste à financer le travail de gravure, très coûteux, par étapes successives
grâce à la contribution de particuliers qui subventionnent des lots de feuilles d’atlas.
Au total, l’Atlas Général de la ville de Paris comporte 54 feuilles traçant un plan de
Paris au 1/2000e 16. Les feuilles 53 et 54 présentent en outre un plan des principales
opérations de triangulation ayant permi de construire l’atlas.
2.4.2 Contenu du plan
Tout comme l’atlas de Verniquet, Jacoubet crée un plan relativement épuré contenant
principalement le tracé des rues et les plans des bâtiments publics. Toutefois,
l’objectif de l’architecte est de faire de son atlas un outil de travail pour la préfecture
de la Seine, mais aussi pour les propriétaires et entrepreneurs parisiens. Pour cette
raison, il rajoute le tracé des alignements prévus par la préfecture en vertu de la loi
du 16 septembre 1807 (cf. le paragraphe 2.6.1), ainsi que les parcelles cadastrales
numérotées. Enfin, les bâtiments à l’intérieur des boulevard sont dessinés en coupe ;
On peut d’ailleurs remarquer, par une étude fine des planches et de l’espace qu’elles
représentent, que les échelles des bâtiments et des autres thèmes cartographiques
ne sont pas toujours identiques. L’échelle des bâtiments est ainsi régulièrement plus
grande que celle des rues et ilôts. Cela s’explique par le fait que les bâtiments figurés
dans l’atlas proviennent très certainement des levés de l’atlas des 48 quartiers de
14. Notamment ceux de Delagrive, Verniquet, Delisle et Jaillot
15. Paris ayant toutefois évolué depuis 1791, notamment aux alentours des boulevards, Jacoubet complète
le canevas de triangle existantRéutilisant en partie les levés de Verniquet, il est possible qu’il se soit cantonné
à lever en détail les parties périphériques de la ville. En effet, contrairement à Verniquet ou même Vasserot,
Jacoubet est presque seul à réaliser son atlas. Seuls quelques employé de la Seine l’aideront à reporter les
calques -c’est à dire les premières minutes- de l’atlas sur les feuilles de l’atlas.
16. L’échelle idiquée sur le plan est de 1 millimètre pour deux mètres 
Vasserot, différents de ceux de Verniquet. On a ici un exemple de réutilisation de
différentes sources cartographiques générant des erreurs dans la carte ainsi consituée
en patchwork. L’atlas est donc globalement hétérogène. Tout d’abord, les bâtiments
à l’exterieur des boulevards sont dessinés en masse, à l’inverse de paris intra-muros.
Le dessin des parcelles est également très inégal. Dans l’extrême centre de Paris
(autour de la place du Châtelet) et de l’exterieur de la ville, toutes les parcelles sont
représentées et numérotées. Partout ailleurs, les parcelles sont seulement ébauchées
et seuls leur numéro et leur amorce sur la rue est dessinés.
Tous ces éléments contribue à faire de l’atlas de Jacoubet un plan majeur du milieu
du 19e siècle mais dont les hétérogénéités appellent à le considérer avec prudence.
Cet atlas et son auteur sont symptomatiques de la mutation que subit la gestion
urbaine au 19e siècle, entamée entre la Révolution et le Premier Empire et qui s’achèvera
par l’arrivée du préfet Haussmann à la tête de la très centralisée préférecture
de la Seine. Pour cette raison, nous proposons en section 2.6 d’explorer plus en profondeur
le personnage de Jacoubet et la réalisation de son grand atlas, ce qui nous
permet de mettre en évidence cette mutation.'
	, sfti_makesfti(1825, 1827, 1836, 1837)
	,  '{"default": 4, "road_axis":2.5, "building":1, "number":2}'::json 
	)
	
	,('poubelle_municipal_paris'
	, 'atlas municipal de paris sous la direction de M. Poubelle'
	, 'super atlas blabla'
	, sfti_makesfti(1887, 1888, 1888, 1889) 
	,  '{"default": 2, "road_axis":2, "building":1, "number":10}'::json 
	) ; 


----- geohistorical_object.numerical_origin_process
-- numerical_origin_process
	SELECT *
	FROM geohistorical_object.numerical_origin_process ; 

	TRUNCATE geohistorical_object.numerical_origin_process  CASCADE; 
	
	INSERT INTO geohistorical_object.numerical_origin_process VALUES
	('default_human_manual'
		, 'A human manually entered these values'
		, 'this is the default option when a human created the data, and you dont want to create a custom numerical_origin_process. You probably should'
		, sfti_makesfti(1995, 1995, 2016, 2016) 
		, '{"default": 1, "road_axis":3, "building":0.5, "number":1.5}'::json)
	,('default_computer_automatic'
		, 'these values are automatically created by a computer'
		, 'this is the default option when a computer created automatically the data, and you dont want to create a custom numerical_origin_process. You probably should, because the precision will greatly depend on your algorithm'
		, sfti_makesfti(1995, 1995, 2016, 2016) 
		, '{"default": 10, "road_axis":5, "building":5, "number":10}'::json) ;


----- geohistorical_object.geohistorical_object
-- geohistorical_object
-- THIS TABLE SHOULD REMAIN EMPTY ! 
-- instead, create another table and inherit from geohistorical_object


	SELECT *
	FROM geohistorical_object.geohistorical_object ;

	DROP TABLE IF EXISTS test_geohistorical_object CASCADE; 
	CREATE TABLE test_geohistorical_object (
		my_custom_uid serial PRIMARY KEY 
	)
	INHERITS (geohistorical_object.geohistorical_object) ;
 

	SELECT geohistorical_object.enable_disable_geohistorical_object(  'public', 'test_geohistorical_object',true)


	 

	-- adding indexes  
	CREATE INDEX ON test_geohistorical_object  USING GIST(geom) ;
	CREATE INDEX ON test_geohistorical_object  USING  GIN (normalised_name gin_trgm_ops);


	SELECT *
	FROM test_geohistorical_object  ;

	INSERT INTO test_geohistorical_object VALUES (
	'rue saint étienne à Paris', 'rue saint etienne, Paris',   ST_GeomFromEWKT('SRID=2154;LINESTRING(0 0 , 10 10, 20 10)')	
	, NULL, NULL
	,'jacoubet_paris',  'default_human_manual'  ),
	(
	'r. st-étienne à Paris', 'r. saint etienne, Paris',   ST_GeomFromEWKT('SRID=2154;LINESTRING(1 1 , 11 11, 21 11)')	
	,  sfti_makesfti('08-06-1888'::date,'08-06-1888','01-09-1888','01-10-1888'), 3
	,'poubelle_municipal_paris',  'default_computer_automatic'   ) ; 

	DROP TABLE IF EXISTS test_geohistorical_object_2 CASCADE; 
	CREATE TABLE test_geohistorical_object_2 (
		example_additional_column serial PRIMARY KEY 
	) INHERITS (test_geohistorical_object)  ; 

	DROP TABLE IF EXISTS test_geohistorical_object_3 CASCADE; 
	CREATE TABLE test_geohistorical_object_3 (
		example_additional_column serial PRIMARY KEY 
	) INHERITS (test_geohistorical_object,  geohistorical_object.normalised_name_alias)  ; 

	SELECT geohistorical_object.enable_disable_geohistorical_object(  'public', 'test_geohistorical_object_2',true),
		geohistorical_object.enable_disable_geohistorical_object(  'public', 'test_geohistorical_object_3',true)



---- geohistorical_object.normalised_name_alias 
-- THIS TABLE SHOULD REMAIN EMPTY ! 
-- instead, create a new table and inherit from it

	SELECT *
	FROM geohistorical_object.normalised_name_alias  ;

	DROP TABLE IF EXISTS test_normalised_name_alias ; 
	CREATE TABLE test_normalised_name_alias (
	my_custom_uid serial PRIMARY KEY -- you can add as amny columns as you want
	)INHERITS (geohistorical_object.normalised_name_alias)  ;

	SELECT geohistorical_object.enable_disable_geohistorical_object(  'public', 'test_normalised_name_alias',true)


	 
	TRUNCATE test_normalised_name_alias CASCADE ; 
	SELECT *
	FROM test_normalised_name_alias ;

	INSERT INTO test_normalised_name_alias VALUES 
	('jacoubet_paris', 'rue saint etienne, Paris', NULL, 'poubelle_municipal_paris', 'r. saint etienne, Paris', NULL, 2)
	, (NULL, 'rue saint etienne', NULL, NULL, 'rue Saint-Etienne, Paris',NULL,  0.1) ;




 