classdef Engine < handle




properties ( SetAccess = private )


ProjectPath string;
end 

properties ( Access = private, Hidden )
UserMessageHandler;
end 

methods 
function obj = Engine( projectPath )

R36
projectPath{ mustBeTextScalar } = "";
end 

projectPath = convertCharsToStrings( projectPath );

if alm.internal.project.isJsEnabled(  )
prj = matlab.internal.project.api.currentProject;
else 
prj = matlab.project.rootProject(  );
end 

if projectPath == ""
if isempty( prj )
error( message( 'dashboard:api:NoCurrentProject' ) );
end 
else 

g = alm.internal.GlobalProjectFactory.get(  );
f = g.createMATLABProjectFactory(  );
f.loadProject( projectPath, false );

prj = currentProject(  );

end 

obj.ProjectPath = prj.RootFolder;


obj.UserMessageHandler = @( service, evt )( onUserMessage( obj, service, evt ) );
end 

ids = getAvailableMetricIds( obj )

updateArtifacts( obj )

execute( obj, metricIDs, varargin )

res = getMetrics( obj, metricID, varargin )

deleteMetrics( obj, metricID, varargin )

openArtifact( obj, artifactUUID )

err = getArtifactErrors( obj )

loc = generateReport( obj, varargin )
end 

methods ( Access = private )

function throwIfDirtyArtifacts( obj )
g_tmp = alm.Graph(  );
as = alm.internal.ArtifactService.get( obj.ProjectPath );
das = as.getDirtyArtifacts( g_tmp );

if ~isempty( das )
artifactsStr = "";

for i = 1:numel( das )
da = das( i );
artifactsStr = artifactsStr + da.getSelfContainedArtifact(  ).Address + newline;
end 

error( message( 'dashboard:api:DirtyArtifacts', artifactsStr ) );
end 
end 

function uuid = getUUIDFromAddress( obj, address, analyze )
if isempty( address )
uuid = '';
else 
if ischar( address )
address = { address };
elseif isstring( address )
address = cellstr( address );
end 

as = alm.internal.ArtifactService.get( obj.ProjectPath );
l = addlistener( as, 'UserNotificationEvent',  ...
obj.getUserMessageHandler(  ) );%#ok<NASGU>

storageFactory = alm.StorageFactory;
storageHandler = storageFactory.createHandler(  ...
as.getGraph(  ).getStorageByCustomId( "ProjectRoot" ) );






if analyze



as.updateArtifacts(  );
end 

G = as.getGraph(  );

art = [  ];

if numel( address ) == 2
art = G.getArtifactByAddress(  ...
"",  ...
storageHandler.getRelativeAddress( address{ 1 } ).Value,  ...
string( address{ 2 } ) );
elseif numel( address ) == 1
art = G.getArtifactByAddress(  ...
"",  ...
storageHandler.getRelativeAddress( address{ 1 } ).Value );
end 

if isempty( art )
error( message( 'dashboard:api:InvalidArtifactScope', address{ 1 } ) );
end 


uuid = art.UUID;
end 
end 

function handler = getUserMessageHandler( obj )
handler = obj.UserMessageHandler;
end 
end 

methods ( Hidden )
function setUserMessageHandler( obj, handler )
obj.UserMessageHandler = handler;
end 

function onUserMessage( ~, ~, evt )

msg = alm.internal.stripHyperlinks( evt.Message );

switch evt.Type
case uint8( 0 )
disp( msg );
case { uint8( 1 ), uint8( 2 ) }

warning( evt.Title, msg );
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp63iy3U.p.
% Please follow local copyright laws when handling this file.

