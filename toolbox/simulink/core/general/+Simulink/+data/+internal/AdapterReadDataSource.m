classdef AdapterReadDataSource < Simulink.data.internal.DataSource





properties ( Hidden )

ResolvedDataSourceId;
Section;
Adapter;

CacheConnContainerMfModel;

SectionToCacheConnectionsMap;
end 


methods ( Access = public )


function obj = AdapterReadDataSource( source, options )
R36
source
options.Section
end 

obj.IsPersistent = true;
if isfield( options, 'Section' )
obj.Section = string( options.Section );
else 
obj.Section = missing;
end 

[ path, ~, ext ] = fileparts( source );
if isempty( path )

obj.ResolvedDataSourceId = which( source );
elseif startsWith( path, '.' )

absolutePath = matlab.io.internal.filesystem.absolutePath( source );
if isfile( absolutePath )
obj.ResolvedDataSourceId = absolutePath;
end 
else 

obj.ResolvedDataSourceId = source;
end 

if isempty( obj.ResolvedDataSourceId )
throwAsCaller( MException( message( 'SLDD:sldd:ImportFileNotFound', source ) ) );
end 

if ~sl.data.adapter.AdapterManagerV2.hasReadingAdapters( obj.ResolvedDataSourceId )
throwAsCaller( MException( message( 'Simulink:Data:NoValidAdapterToReadSource', obj.ResolvedDataSourceId ) ) );
end 

obj.CacheConnContainerMfModel = mf.zero.Model;
obj.SectionToCacheConnectionsMap = containers.Map;
try 
availableSections = string( sl.data.srccache.Util.getReadableSections( obj.ResolvedDataSourceId ) );
catch ME
throwAsCaller( ME );
end 

if ismissing( obj.Section )
obj.Section = availableSections;
if strcmp( ext, '.mat' )



sectionReturnedFromAdapterV1 = "MATFileAdapter";
obj.Section( strcmp( obj.Section, sectionReturnedFromAdapterV1 ) ) = [  ];
end 
end 

for aSection = obj.Section
try 
dataSrcInfo = sl.data.srccache.DataSourceInfo.createObject( obj.ResolvedDataSourceId, aSection,  ...
obj.CacheConnContainerMfModel );
obj.SectionToCacheConnectionsMap( aSection ) =  ...
sl.data.srccache.CacheConnection.createConnection( dataSrcInfo, obj.CacheConnContainerMfModel );
catch ME
ex = MException( message( 'Simulink:Data:CannotMakeConnection', source, aSection ) );
ex = ex.addCause( ME );
throwAsCaller( ex );
end 
end 
end 


function delete( obj )
if isempty( obj )
return ;
end 

if ~isempty( obj.SectionToCacheConnectionsMap )
for aConn = values( obj.SectionToCacheConnectionsMap )
aConn{ 1 }.closeConnection;
end 
end 

if ( ~isempty( obj.CacheConnContainerMfModel ) )
obj.CacheConnContainerMfModel.destroy;
end 
end 


function varIDs = identifyVisibleVariables( obj )
tmpMFModel = mf.zero.Model;
varIDs = [  ];
for aSection = keys( obj.SectionToCacheConnectionsMap )
aConn = obj.SectionToCacheConnectionsMap( aSection{ 1 } );

try 
aConn.updateCacheFromSources( tmpMFModel );
catch 
end 

aConnData = aConn.getAllData( tmpMFModel );
aConnVarIDs = Simulink.data.VariableIdentifier.empty( size( aConnData, 2 ), 0 );
for idx = 1:size( aConnData, 2 )
varSection = char( aSection );
uniqueVarId = strcat( varSection, '#', aConnData( idx ).name );
aConnVarIDs( idx ) = Simulink.data.VariableIdentifier( aConnData( idx ).name,  ...
uniqueVarId,  ...
aConnData( idx ).source );
end 
varIDs = [ varIDs;aConnVarIDs' ];%#ok
end 
end 

function identifyVisibleVariablesByClass( ~, ~ )
assert( true, 'Functionality has been replaced by new API' );
end 


function varIDs = identifyVisibleVariablesDerivedFromClass( ~, ~ )
varIDs = [  ];
assert( true, 'AdapterReadDataSource:identifyVisibleVariablesDerivedFromClass not implemented yet' );
end 


function identifyByName( ~, ~ )
assert( true, 'Functionality has been replaced by new API' );
end 


function isVisible = isVariableVisible( ~, ~ )
isVisible = [  ];
assert( true, 'AdapterReadDataSource:isVariableVisible not implemented yet' );
end 


function value = getVariable( obj, varID )
value = [  ];
tmpMFModel = mf.zero.Model;
if startsWith( varID.VariableIdWithinSource, '#' )
varSection = "";
else 
varSection = strtok( varID.VariableIdWithinSource, '#' );
end 
if isKey( obj.SectionToCacheConnectionsMap, varSection )
aConn = obj.SectionToCacheConnectionsMap( varSection );
dataInfo = aConn.getDataByName( varID.Name, tmpMFModel );
value = dataInfo.getMatValue;
end 
end 


function [ varID, isCreatedInPersistentSource ] = createVariable( ~, ~, ~ )
varID = [  ];
isCreatedInPersistentSource = [  ];
assert( true, 'AdapterReadDataSource:createVariable not implemented yet' );
end 


function success = updateVariable( ~, ~, ~ )
success = false;
assert( true, 'AdapterReadDataSource:updateVariable not implemented yet' );
end 


function success = deleteVariable( ~, ~ )
success = false;
assert( true, 'AdapterReadDataSource:deleteVariable not implemented yet' );
end 


function success = save( ~ )
success = false;
assert( true, 'AdapterReadDataSource:save not implemented yet' );
end 


function success = revert( ~ )
success = false;
assert( true, 'AdapterReadDataSource:revert not implemented yet' );
end 


function showVariableInUI( ~, ~ )
assert( true, 'AdapterReadDataSource:showVariableInUI not implemented yet' );
end 


function openBusEditor( ~, ~ )
assert( true, 'AdapterReadDataSource:openBusEditor not implemented yet' );
end 


function showVariableInModelExplorer( ~, ~ )
assert( true, 'AdapterReadDataSource:showVariableInModelExplorer not implemented yet' );
end 


function removeCruft( ~, ~ )
assert( true, 'AdapterReadDataSource:removeCruft not implemented yet' );
end 


function varExist = hasVariable( ~, ~ )
varExist = [  ];
assert( true, 'AdapterReadDataSource:removeCruft not implemented yet' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpnElfcw.p.
% Please follow local copyright laws when handling this file.

