classdef ( Hidden )dataStore



properties 
m_dbconnection;
end 
methods 
function registerFolderImplementation( this, path, verbose )



modelPathsStruct = [ dir( fullfile( path, '**/*.slx' ) ); ...
dir( fullfile( path, '**/*.mdl' ) ) ];

for pathIdx = 1:length( modelPathsStruct )
modelPath = fullfile( modelPathsStruct( pathIdx ).folder,  ...
modelPathsStruct( pathIdx ).name );
this.registerModel( modelPath, 'verbose', verbose );
end 

end 
function registerModelImplementation( this, path, verbose )


internalModels = { [ 'internal', filesep ], [ 'nonshipping', filesep ] };
if contains( path, internalModels )
return ;
end 


normalizedPath = this.normalizePath( path );
[ ~, modelName, ~ ] = fileparts( normalizedPath );


this.m_dbconnection.doSql( this.SQLSelectExistsMODELSPath( normalizedPath ) );
modelExistsInDB = this.m_dbconnection.fetchRows{ 1 }{ 1 };

if modelExistsInDB
if verbose == "on"
disp( getString( message( 'modelfinder:error:FileExistsInDB', normalizedPath ) ) );
end 
return ;
else 
this.m_dbconnection.doSql( this.SQLInsertMODELSNamePath( modelName, normalizedPath ) );
if verbose == "on"
disp( getString( message( 'modelfinder:error:AddedToDB', normalizedPath ) ) );
end 
end 
end 
function registerProjectImplementation( this, prjRoot, prjPath, prjArchive, prjHelperCmd )
[ ~, exampleName, ~ ] = fileparts( prjPath );
if isempty( prjArchive )
componentName = this.normalizePath( prjPath );
else 
componentName = this.normalizePath( prjArchive );
exampleName = [ char( exampleName ), ';', prjHelperCmd ];
end 
product = char( "" );
docText = char( "" );


this.m_dbconnection.doSql( this.SQLSelectExistsEXAMPLESComponentName( componentName, exampleName ) );
exampleExistsInDB = this.m_dbconnection.fetchRows{ 1 }{ 1 };
if ~exampleExistsInDB
this.m_dbconnection.doSql( this.SQLInsertEXAMPLESAll( componentName, exampleName, product, docText ) );
end 


this.registerFolder( prjRoot );


this.m_dbconnection.doSql( this.SQLSelectEXAMPLESExampleid( componentName, exampleName ) );
eID = this.m_dbconnection.fetchRows;
eID = eID{ 1 }{ 1 };


this.m_dbconnection.doSql( this.SQLSelectMODELSModelids( this.normalizePath( prjRoot ) ) );
mIDs = this.m_dbconnection.fetchRows;


for mID = mIDs
this.m_dbconnection.doSql( this.SQLInsertEXADELAll( eID, mID{ 1 }{ 1 } ) );
end 
end 
function unregisterFolderImplementation( this, path )



if path == matlabroot
modelfinder.unregisterFolder( [ fullfile( matlabroot, "help" ), fullfile( matlabroot, "toolbox" ), fullfile( matlabroot, "examples" ) ] );
end 


normalizedPath = this.normalizePath( path );

if ~isempty( normalizedPath )
normalizedPath = [ normalizedPath, '/' ];
end 

this.m_dbconnection.doSql( this.SQLSetMarkForDeleteGlobPath( normalizedPath ) );

end 
function syncImplementation( this, path, verbose )
if verbose == "on"
disp( getString( message( 'modelfinder:error:SyncStart' ) ) );
end 


query = this.SQLDeleteAllMarkedForDelete(  );
this.m_dbconnection.doSql( query{ 1 } );
this.m_dbconnection.doSql( query{ 2 } );
this.m_dbconnection.doSql( query{ 3 } );


if path ~= ""
normalizedFolderPath = this.normalizePath( path );
this.m_dbconnection.doSql( this.SQLSelectMODELSPathChecksumGlobPath( char( normalizedFolderPath ) ) );
else 
this.m_dbconnection.doSql( this.SQLSelectMODELSPathChecksum(  ) );
end 
pathChecksumCell = this.m_dbconnection.fetchRows;


this.m_dbconnection.beginTransaction( '' );
try 
for pathIdx = 1:length( pathChecksumCell )
normalizedPath = pathChecksumCell{ pathIdx }{ 1 };
[ modelPath, isPathValid ] = this.getAbsolutePath( normalizedPath );
if ~isPathValid
if verbose == "on"
disp( getString( message( 'modelfinder:error:SkipInvalidPath', normalizedPath ) ) );
end 

this.m_dbconnection.doSql( this.SQLSetMarkForDeletePath( normalizedPath ) );
continue ;
end 
newChecksum = Simulink.getFileChecksum( modelPath );
oldChecksum = pathChecksumCell{ pathIdx }{ 2 };

if ~strcmp( newChecksum, oldChecksum )

this.syncModelMetadata( modelPath, newChecksum, verbose );
end 
end 
catch 
end 
this.m_dbconnection.commitTransaction( '' );
if verbose == "on"
disp( getString( message( 'modelfinder:error:RemoveStaleEntries' ) ) );
end 


query = this.SQLDeleteAllMarkedForDelete(  );
this.m_dbconnection.doSql( query{ 1 } );
this.m_dbconnection.doSql( query{ 2 } );
this.m_dbconnection.doSql( query{ 3 } );


this.m_dbconnection.doSql( this.SQLDropFTSJOINED(  ) );
this.m_dbconnection.doSql( this.SQLCreateFTSJOINED(  ) );
this.m_dbconnection.doSql( this.SQLInsertFTSJOINEDAll(  ) );

if verbose == "on"
disp( getString( message( 'modelfinder:error:SyncComplete' ) ) );
end 
end 
function registerExamplesImplementation( this, XMLFiles, verbose )


numXMLFiles = length( XMLFiles );
for XMLFileIdx = 1:numXMLFiles
try 
XMLStruct = readstruct( XMLFiles( XMLFileIdx ) );
demoItems = XMLStruct.demoitem';
if verbose == "on"
disp( getString( message( 'modelfinder:error:ParseXML', XMLFiles( XMLFileIdx ) ) ) );
end 
catch 
if verbose == "on"
disp( getString( message( 'modelfinder:error:SkipInvalidXML', XMLFiles( XMLFileIdx ) ) ) );
end 
continue ;
end 


XMLDir = fileparts( XMLFiles( XMLFileIdx ) );
[ ~, componentName ] = fileparts( XMLDir );
componentName = char( componentName );

for demoIdx = 1:length( demoItems )
try 
filesInDemoItem = [ demoItems( demoIdx ).file.Text ]';
catch 
continue ;
end 

[ ~, ~, fileExts ] = fileparts( filesInDemoItem );
validModelFiles = filesInDemoItem( fileExts == ".slx" | fileExts == ".mdl" );
exampleName = char( demoItems( demoIdx ).source );

if isempty( validModelFiles )
continue ;
else 
this.m_dbconnection.doSql( this.SQLSelectExistsEXAMPLESComponentName( componentName, exampleName ) );
exampleExistsInDB = this.m_dbconnection.fetchRows{ 1 }{ 1 };
if ~exampleExistsInDB
product = char( strjoin( demoItems( demoIdx ).product, ';' ) );
docText = char( "" );
this.m_dbconnection.doSql( this.SQLInsertEXAMPLESAll( componentName, exampleName, product, docText ) );
end 
end 


validModelFiles = fullfile( XMLDir, "main", validModelFiles );

for k = 1:length( validModelFiles )
this.registerModel( validModelFiles( k ), "verbose", verbose );

this.m_dbconnection.doSql( this.SQLSelectEXAMPLESExampleid( componentName, exampleName ) );
eID = this.m_dbconnection.fetchRows;
if ~isempty( eID )
eID = eID{ 1 }{ 1 };
else 
continue ;
end 
normalizedModelPath = this.normalizePath( validModelFiles( k ) );

this.m_dbconnection.doSql( this.SQLSelectMODELSModelid( normalizedModelPath ) );
mID = this.m_dbconnection.fetchRows;
if ~isempty( mID )
mID = mID{ 1 }{ 1 };
else 
continue ;
end 

this.m_dbconnection.doSql( this.SQLInsertEXADELAll( eID, mID ) );
end 
end 
end 
end 
function syncModelMetadata( this, modelPath, newChecksum, verbose )

normalizedModelPath = this.normalizePath( modelPath );

modelInfo = Simulink.MDLInfo( modelPath );


if ( modelInfo.IsLibrary || ( string( modelInfo.BlockDiagramType ) == "Subsystem" ) )
if verbose == "on"
disp( getString( message( 'modelfinder:error:SkipLibrarySubsystem', normalizedModelPath ) ) );
end 
this.m_dbconnection.doSql( this.SQLSetMarkForDeletePath( normalizedModelPath ) );
return ;
end 


checksum = newChecksum;


description = modelInfo.Description;
description = regexprep( description, { '''', '"' }, '' );
description = regexprep( description, '[\n\r\s]+', ' ' );


slsQuery = Simulink.loadsave.Query( "//*/Annotation/Name" );
slsMatches = Simulink.loadsave.findAll( modelPath, slsQuery );
allAnno = string( { slsMatches{ : }.Value }' );



bodyText = regexp( allAnno, '<body.*?/body>', 'ignorecase', 'match' );
for annoIdx = 1:length( bodyText )
if ~isempty( bodyText{ annoIdx } )

allAnno( annoIdx ) = regexprep( bodyText{ annoIdx }, '<.*?>', '' );
else 

allAnno( annoIdx ) = allAnno{ annoIdx };
end 
end 

allAnno = regexprep( allAnno, { '''', '"' }, '' );
allAnno = regexprep( allAnno, '[\n\r\s]+', ' ' );
annotation = char( strjoin( allAnno ) );
if isempty( annotation )
annotation = '';
end 


slsQuery = Simulink.loadsave.Query( "//*/Block/SourceType" );
slsMatches = Simulink.loadsave.findAll( modelPath, slsQuery );
libBlockTypes = string( { slsMatches{ : }.Value } )';


slsQuery = Simulink.loadsave.Query( "//*/Block/BlockType" );
slsMatches = Simulink.loadsave.findAll( modelPath, slsQuery );
coreBlockTypes = string( { slsMatches{ : }.Value } )';


slsQuery = Simulink.loadsave.Query( "//*/Block/Name" );
slsMatches = Simulink.loadsave.findAll( modelPath, slsQuery );
blockNames = string( { slsMatches{ : }.Value } )';
blockNames = regexprep( blockNames, { '\d+$', '"', '''' }, '' );



blocksList = unique( regexprep( [ libBlockTypes;coreBlockTypes;blockNames ], '[\n\r\s]+', ' ' ) );

blocks = char( strjoin( blocksList, ';' ) );


this.m_dbconnection.doSql( this.SQLInsertMODELSAll( checksum, description, annotation, blocks, normalizedModelPath ) );


disp( getString( message( 'modelfinder:error:Synced', normalizedModelPath ) ) );
end 
end 
methods ( Access = 'protected' )

function obj = dataStore(  )

aDBFilePath = modelfinder.internal.queryEngine.getActiveDBFilePath(  );
obj.m_dbconnection = matlab.depfun.internal.database.SqlDbConnector(  );
[ ~ ] = modelfinder.internal.queryEngine.instance(  );
obj.m_dbconnection.connect( aDBFilePath );
end 

function delete( obj )
obj.m_dbconnection.disconnect;
end 
end 
methods ( Static )
function registerFolder( path, options )
R36
path
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 
modelfinder.internal.dataStore.instance(  ).registerFolderImplementation( path, options.verbose );
end 
function registerModel( path, options )
R36
path
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 
modelfinder.internal.dataStore.instance(  ).registerModelImplementation( path, options.verbose );
end 
function registerProject( prjRoot, prjPath, prjArchive, prjHelperCmd )
R36
prjRoot{ mustBeFolder }
prjPath{ mustBeFile, mustBeTextScalar, mustBeNonzeroLengthText }
prjArchive = ''
prjHelperCmd = ''
end 
modelfinder.internal.dataStore.instance(  ).registerProjectImplementation( prjRoot, prjPath, prjArchive, prjHelperCmd );
end 
function registerExamples( XMLFiles, options )
R36
XMLFiles
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 
modelfinder.internal.dataStore.instance(  ).registerExamplesImplementation( XMLFiles, options.verbose );
end 
function sync( options )
R36
options.path = ""
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 
modelfinder.internal.dataStore.instance(  ).syncImplementation( options.path, options.verbose );
end 
function unregisterFolder( path )
modelfinder.internal.dataStore.instance(  ).unregisterFolderImplementation( path );
end 
end 
methods ( Static, Hidden )
function deleteInstance(  )
obj.m_dbconnection.disconnect;
end 
function obj = instance( ~ )
persistent finder_instance;
if isempty( finder_instance )
finder_instance = modelfinder.internal.dataStore(  );
end 
obj = finder_instance;
end 
function normalizedPath = normalizePath( path )





normalizedPath = char( erase( path, [ matlabroot, filesep ] ) );


normalizedPath = regexprep( normalizedPath, '\', '/' );
end 
function [ absolutePath, isPathValid ] = getAbsolutePath( normalizedPath )
isPathValid = true;
modifiedPath = fullfile( matlabroot, normalizedPath );

if isfile( normalizedPath )
absolutePath = normalizedPath;
elseif isfile( modifiedPath )
absolutePath = modifiedPath;
else 
isPathValid = false;
absolutePath = [  ];
end 
end 
end 





methods ( Static, Hidden )
function query = SQLSelectExistsMODELSPath( normalizedPath )
query = [ 'SELECT EXISTS(SELECT 1 FROM MODELS WHERE PATH IS "', normalizedPath, '");' ];
end 
function query = SQLSelectExistsEXAMPLESComponentName( componentName, exampleName )
query = [ 'SELECT EXISTS(SELECT 1 FROM EXAMPLES WHERE COMPONENT IS "', componentName, '" AND EXAMPLENAME IS "', exampleName, '");' ];
end 
function query = SQLSelectEXAMPLESExampleid( componentName, exampleName )
query = [ 'SELECT exampleID from EXAMPLES where COMPONENT IS "', componentName, '" AND EXAMPLENAME IS "', exampleName, '";' ];
end 
function query = SQLSelectMODELSModelid( normalizedModelPath )
query = [ 'SELECT modelID from MODELS where PATH IS "', normalizedModelPath, '";' ];
end 
function query = SQLSelectMODELSModelids( normalizedModelPath )
query = [ 'SELECT modelID from MODELS where PATH GLOB "', normalizedModelPath, '/*";' ];
end 
function query = SQLInsertMODELSNamePath( modelName, normalizedPath )
query = [ 'INSERT INTO MODELS(MODELNAME, PATH) VALUES("', modelName, '","', normalizedPath, '")' ];
end 
function query = SQLInsertEXAMPLESAll( componentName, exampleName, product, docText )
query = [ 'INSERT INTO EXAMPLES(COMPONENT, EXAMPLENAME, PRODUCT, DOC) VALUES("', componentName, '","', exampleName, '","', product, '","', docText, '");' ];
end 
function query = SQLInsertMODELSAll( checksum, description, annotation, blocks, normalizedModelPath )
query = [ 'UPDATE MODELS SET CHECKSUM = "', checksum, '",DESCRIPTION = "', description, '",ANNOTATION = "', annotation, '",BLOCK = "', blocks, '" WHERE PATH is "', normalizedModelPath, '";' ];
end 
function query = SQLInsertEXADELAll( eID, mID )
query = [ 'INSERT OR IGNORE INTO EXADEL(eID,mID) VALUES(', num2str( eID ), ',', num2str( mID ), ');' ];
end 
function query = SQLSetMarkForDeleteGlobPath( normalizedPath )
query = [ 'UPDATE MODELS SET MARKFORDELETE=1 WHERE PATH GLOB "', normalizedPath, '*";' ];
end 
function query = SQLSetMarkForDeletePath( normalizedModelPath )
query = [ 'UPDATE MODELS SET MARKFORDELETE=1 WHERE PATH IS "', normalizedModelPath, '";' ];
end 
function query = SQLDeleteAllMarkedForDelete(  )
query{ 1 } = 'DELETE FROM EXADEL where exadel.mID IN (SELECT modelID from MODELS where MARKFORDELETE=1);';
query{ 2 } = 'DELETE FROM MODELS where MARKFORDELETE is 1;';
query{ 3 } = 'DELETE FROM EXAMPLES where examples.exampleID NOT IN (SELECT DISTINCT(exadel.eID) FROM EXADEL);';
end 
function query = SQLSelectMODELSPathChecksum(  )
query = 'SELECT path,IFNULL(checksum,"EMPTY_CHECKSUM") from MODELS;';
end 
function query = SQLSelectMODELSPathChecksumGlobPath( normalizedPath )
query = [ 'SELECT path,IFNULL(checksum,"EMPTY_CHECKSUM") from MODELS WHERE PATH GLOB "', normalizedPath, '*";' ];
end 
function query = SQLDropFTSJOINED(  )
query = 'DROP TABLE IF EXISTS FTSJOINED;';
end 
function query = SQLCreateFTSJOINED(  )
query = 'CREATE VIRTUAL TABLE FTSJOINED USING fts4(modelID INTEGER,MODELNAME VARCHAR,PATH VARCHAR,DESCRIPTION VARCHAR,ANNOTATION VARCHAR,BLOCK VARCHAR,exampleID INTEGER,COMPONENT VARCHAR,EXAMPLENAME VARCHAR,PRODUCT VARCHAR,DOC VARCHAR);';
end 
function query = SQLSelectExistsSQLITEMASTERFtsjoined(  )
query = 'SELECT COUNT(1) FROM sqlite_master where type="table" AND name="FTSJOINED"';
end 
function query = SQLInsertFTSJOINEDAll(  )
query = [ 'INSERT INTO FTSJOINED SELECT  m.modelID, ' ...
, 'm.MODELNAME, ' ...
, 'm.PATH, ' ...
, 'm.DESCRIPTION, ' ...
, 'm.ANNOTATION, ' ...
, 'm.BLOCK, ' ...
, 'e.exampleID, ' ...
, 'IFNULL(e.COMPONENT,"EMPTY_COMPONENT"), ' ...
, 'IFNULL(e.EXAMPLENAME,"EMPTY_EXAMPLENAME"), ' ...
, 'IFNULL(e.PRODUCT,"EMPTY_PRODUCT"), ' ...
, 'e.DOC ' ...
, 'FROM models m ' ...
, 'LEFT JOIN exadel em ' ...
, 'ON m.modelID = em.mID ' ...
, 'LEFT JOIN examples e ' ...
, 'ON em.eID = e.exampleID ' ...
, 'ORDER BY e.EXAMPLENAME;' ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_ijcQC.p.
% Please follow local copyright laws when handling this file.

