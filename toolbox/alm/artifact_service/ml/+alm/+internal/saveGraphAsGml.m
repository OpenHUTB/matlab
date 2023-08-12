
























function saveGraphAsGml( fileName, NameVarArgs )

R36
fileName{ mustBeText }
NameVarArgs.Graph{ mustBeUnderlyingType( NameVarArgs.Graph, "alm.Graph" ) } = alm.Graph.empty(  )
NameVarArgs.SelfContainedGrouping{ mustBeNumericOrLogical } = false
NameVarArgs.Connections{ mustBeUnderlyingType( NameVarArgs.Connections, "alm.gdb.Connection" ) } = alm.gdb.Connection.empty
NameVarArgs.PlotConnections{ mustBeNumericOrLogical } = false
end 

fileName = convertCharsToStrings( fileName );

if NameVarArgs.PlotConnections
assert( numel( NameVarArgs.Connections ) > 0, "'PlotConnections' requires" +  ...
" at least one valid connection to be passed." );
end 

if NameVarArgs.SelfContainedGrouping
assert( ~NameVarArgs.PlotConnections, "'SelfContainedGrouping' is not compatible with 'PlotConnections." );
assert( isempty( NameVarArgs.Connections ), "'SelfContainedGrouping' is not compatible with 'Connections." );
end 


if isempty( NameVarArgs.Graph )
project = currentProject(  );
artifactService = alm.internal.ArtifactService.get( project.RootFolder );
g = artifactService.getGraph(  );
else 
g = NameVarArgs.Graph;
end 



file = fopen( fileName, 'wt' );
writeLine( file, 'graph [' );
writeLine( file, '  directed 1' );


if NameVarArgs.SelfContainedGrouping
allFileArtifacts = g.getAllFileArtifacts(  );
for fileArtifact = allFileArtifacts
if ~strcmp( fileArtifact.Type, 'atomic_file' )
id = [ 'G', fileArtifact.UUID ];
type = 'rectangle';
label = fileArtifact.Label;
width = 1;
fill = '#FFFFFF';
[ w, h ] = nodeSize( label );
writeGroupNode( file, id, label, width, type, fill, w, h );
end 
end 
end 



mgr = alm.internal.HandlerServiceManager.get(  );
md = mgr.getInstalledServicesMetaData(  );
[ ~, I ] = sort( { md.Id } );
md = md( I );
colorMap = containers.Map;
colors = parula( numel( md ) );

hexColors = {  };
for i = 1:size( colors, 1 )
hexColors{ end  + 1 } = char( erase( strjoin( string( dec2hex( int32( colors( i, : ) * 255 )' ) )' ), " " ) );
end 

for i = 1:numel( md )
types = [ md( i ).FileTypes;md( i ).ElementTypes ];
if ~isempty( types )
for j = 1:numel( types )
colorMap( types{ j } ) = hexColors{ i };
end 
end 
end 


itemMap = containers.Map;
for i = 1:numel( NameVarArgs.Connections )
con = NameVarArgs.Connections( i );
itemMap( con.getLeftItem(  ).UUID ) = con.getLeftItem(  );
itemMap( con.getRightItem(  ).UUID ) = con.getRightItem(  );
end 



allArtifacts = g.getAllArtifacts(  );


if numel( NameVarArgs.Connections ) > 0
lgx = isKey( itemMap, { allArtifacts.UUID } );
allArtifacts = allArtifacts( lgx );
end 

for artifact = allArtifacts
id = artifact.UUID;
type = artifact.Type;

if isKey( colorMap, artifact.Type )
fill = [ '#', colorMap( artifact.Type ) ];
else 
fill = '#FFFFFF';
end 

switch type
case 'sl_req_link'
label = artifact.Address;
width = 1;
type = 'circle';
fill = '#FFFFFF';
w = 20;
h = 20;
otherwise 
label = [ type, newline, artifact.Label ];
if artifact.isFile(  )
width = 3;
else 
width = 1;
end 
type = 'rectangle';
[ w, h ] = nodeSize( label );
end 

gid = '';
if NameVarArgs.SelfContainedGrouping
if artifact.isFile(  )
gid = [ 'G', artifact.UUID ];
else 
a_sc = artifact.getSelfContainedArtifact(  );
if ~isempty( a_sc )
gid = [ 'G', a_sc.UUID ];
end 
end 
end 
writeNode( file, id, label, width, type, fill, w, h, gid )

end 

allTaskEvidences = g.getAllTaskEvidences(  );


if numel( NameVarArgs.Connections ) > 0
lgx = isKey( itemMap, { allTaskEvidences.UUID } );
allTaskEvidences = allTaskEvidences( lgx );
end 

for taskEvidence = allTaskEvidences
id = taskEvidence.UUID;
type = taskEvidence.Type;
switch type
otherwise 
label = type;
width = 1;
type = 'roundrectangle';
fill = '#F76F6F';
[ w, h ] = nodeSize( label );
end 
writeNode( file, id, label, width, type, fill, w, h, '' );
end 

allSlots = g.getAllSlots(  );


if numel( NameVarArgs.Connections ) > 0
lgx = isKey( itemMap, { allSlots.UUID } );
allSlots = allSlots( lgx );
end 

for slot = allSlots
if ~slot.Container.IsConnected
id = slot.UUID;
label = 'Slot';
width = 1;
type = 'circle';
fill = '#FFFFFF';
w = 30;
h = 30;
writeNode( file, id, label, width, type, fill, w, h, gid );
end 
end 

if NameVarArgs.PlotConnections

width = 1;
style = 'line';
fill = '#000000';
sourceArrow = 'none';
targetArrow = 'standard';

for i = 1:numel( NameVarArgs.Connections )
c = NameVarArgs.Connections( i );
sourceId = c.getLeftItem.UUID;
targetId = c.getRightItem.UUID;

writeEdge( file, sourceId, targetId, width, style, fill,  ...
sourceArrow, targetArrow );
end 

else 

if numel( NameVarArgs.Connections ) > 0
allRelationships = alm.Relationship.empty( numel( NameVarArgs.Connections ), 0 );
for i = 1:numel( NameVarArgs.Connections )
allRelationships( i ) = NameVarArgs.Connections( i ).getRelationship(  );
end 
else 
allRelationships = g.getAllRelationships(  );
end 

for relationship = allRelationships
sourceId = relationship.SourceItem.UUID;
targetId = relationship.DestinationItem.UUID;
type = relationship.Type;
switch type
case alm.RelationshipType.CONTAINS
width = 1;
style = 'line';
fill = '#000000';
sourceArrow = 'diamond';
targetArrow = 'none';
case alm.RelationshipType.REQUIRES
width = 1;
style = 'line';
fill = '#FF0000';
sourceArrow = 'none';
targetArrow = 'standard';
case alm.RelationshipType.DERIVES
width = 1;
style = 'dashed';
fill = '#000000';
sourceArrow = 'none';
targetArrow = 'standard';
case alm.RelationshipType.TRACES
width = 1;
style = 'dotted';
fill = '#000000';
sourceArrow = 'none';
targetArrow = 'standard';
otherwise 
width = 1;
style = 'line';
fill = '#000000';
sourceArrow = 'diamond';
targetArrow = 'none';
end 
writeEdge( file, sourceId, targetId, width, style, fill,  ...
sourceArrow, targetArrow )
end 
end 

writeLine( file, ']' );
fclose( file );
end 

function writeLine( file, line, varargin )
fprintf( file, line, varargin{ : } );
fprintf( file, '\n' );
end 

function writeNode( file, id, label, width, type, fill, w, h, gid )
label = strrep( label, '&', '&amp;' );
writeLine( file, '  node [' );
writeLine( file, '    id "%s"', id );
writeLine( file, '    label "%s"', label );
if ~isempty( gid )
writeLine( file, '    gid "%s"', gid );
end 
writeLine( file, '    graphics [' );
writeLine( file, '      width %d', width );
writeLine( file, '      type "%s"', type );
writeLine( file, '      fill "%s"', fill );
writeLine( file, '      w %d', w );
writeLine( file, '      h %d', h );
writeLine( file, '    ]' );
writeLine( file, '  ]' );
end 

function writeGroupNode( file, id, label, width, type, fill, w, h )
writeLine( file, '  node [' );
writeLine( file, '    id "%s"', id );
writeLine( file, '    label "%s"', label );
writeLine( file, '    isGroup 1' );
writeLine( file, '    graphics [' );
writeLine( file, '      width %d', width );
writeLine( file, '      type "%s"', type );
writeLine( file, '      fill "%s"', fill );
writeLine( file, '      w %d', w );
writeLine( file, '      h %d', h );
writeLine( file, '    ]' );
writeLine( file, '  ]' );
end 

function writeEdge( file, sourceId, targetId, width, style, fill, sourceArrow, targetArrow )
writeLine( file, '  edge [' );
writeLine( file, '    source "%s"', sourceId );
writeLine( file, '    target "%s"', targetId );
writeLine( file, '    graphics [' );
writeLine( file, '      width %d', width );
writeLine( file, '      style "%s"', style );
writeLine( file, '      fill "%s"', fill );
writeLine( file, '      sourceArrow "%s"', sourceArrow );
writeLine( file, '      targetArrow "%s"', targetArrow );
writeLine( file, '    ]' );
writeLine( file, '  ]' );
end 

function [ w, h ] = nodeSize( label )
lines = strsplit( label, newline );
numRows = numel( lines );
numCols = max( cellfun( @numel, lines ) );
w = 10 + numCols * 6;
h = 10 + numRows * 10;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp4_6qzR.p.
% Please follow local copyright laws when handling this file.

