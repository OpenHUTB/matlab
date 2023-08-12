function deps = resolveExternalRequirementLinks( handler, node, type, compFactory, filePath, harnessUUID )



R36
handler( 1, 1 )
node( 1, 1 )dependencies.internal.graph.Node
type( 1, 1 )dependencies.internal.graph.Type
compFactory( 1, 1 )function_handle = @( ~, node )dependencies.internal.graph.Component.createRoot( node )
filePath( 1, : )char = node.Path
harnessUUID( 1, 1 )string = i_getHarnessUUID( node, filePath )
end 

persistent slInstalled;
if isempty( slInstalled )
slInstalled = dependencies.internal.util.isProductInstalled( 'SL', 'simulink' );
end 

deps = dependencies.internal.graph.Dependency.empty;


if ~slInstalled
return ;
end 

if ismissing( harnessUUID )

return ;
end 

set = slreq.data.ReqData.getInstance.getLinkSet( filePath );

isNotHarness = harnessUUID == "";

if isempty( set )
if rmimap.loadReq( filePath )

set = slreq.data.ReqData.getInstance.getLinkSet( filePath );
discardSet = onCleanup( @(  )set.discard(  ) );
if isNotHarness
deps = createLinkSetDep( node, set );
end 
elseif dependencies.internal.analysis.simulink.hasSlxQueries( filePath )

reader = Simulink.loadsave.SLXPackageReader( filePath );
if reader.hasPart( '/slreqdata/_linkset.slmx' )
tmpDir = tempname;
tmpFile = fullfile( tmpDir, '_linkset.slmx' );
deleteFolder = onCleanup( @(  )rmdir( tmpDir, 's' ) );
mkdir( tmpDir );
reader.readPartToFile( '/slreqdata/_linkset.slmx', tmpFile );
set = slreq.data.ReqData.getInstance.loadLinkSet( filePath, tmpFile );
discardSet = onCleanup( @(  )set.discard(  ) );
end 
end 
elseif isNotHarness

deps = createLinkSetDep( node, set );
end 

if ~isempty( set )
items = set.getLinkedItems;
deps = [ deps, resolveLinkedItems( node, compFactory, type, items, harnessUUID ) ];
end 
end 

function uuid = i_getHarnessUUID( node, filePath )
if node.Type == dependencies.internal.graph.Type.TEST_HARNESS
harnessUUID = findUUID( filePath, node.Location{ 3 } );
if isempty( harnessUUID )
uuid = missing;
else 
uuid = string( harnessUUID );
end 
else 
uuid = "";
end 
end 

function uuid = findUUID( ownerModelPath, harnessName )
q = Simulink.loadsave.Query( [ '/HarnessInformation/Harness[Name="', harnessName, '"]/HarnessUUID' ] );
uuidMatches = Simulink.loadsave.findAll( ownerModelPath, q );
if isempty( uuidMatches{ 1 } )
uuid = '';
else 
uuid = uuidMatches{ 1 }( 1 ).Value;
end 
end 

function dep = createLinkSetDep( node, set )
linkSetPath = set.filepath;
linkNode = dependencies.internal.graph.Node.createFileNode( linkSetPath );

if ~linkNode.Resolved

[ filePath, name, ~ ] = fileparts( node.Path );
linkSetPath = fullfile( filePath, strcat( name, '.req' ) );
linkNode = dependencies.internal.graph.Node.createFileNode( linkSetPath );
end 

if linkNode.Resolved

linkSetDepType = dependencies.internal.analysis.simulink.RequirementLinkSetNodeAnalyzer.RequirementLinkSetNodeAnalyzerType;
dep = dependencies.internal.graph.Dependency( node, "", linkNode, "", linkSetDepType );
else 

dep = dependencies.internal.graph.Dependency.empty;
end 
end 

function deps = resolveLinkedItems( node, compFactory, type, items, uuid )
import dependencies.internal.util.resolveRequirementLink;

if uuid == ""
shouldSkip = @( id )startsWith( id, ':urn:uuid:' );
adapt = @( id )id;
else 
urn = ":urn:uuid:" + uuid;
shouldSkip = @( id )~startsWith( id, urn );
adapt = @( id )extractAfter( id, urn );
end 

deps = dependencies.internal.graph.Dependency.empty;
for item = items
if shouldSkip( item.id )
continue ;
end 
component = compFactory( adapt( item.id ), node );
links = item.getLinks;
for link = links
deps = [ deps, resolveRequirementLink( node, component, link.destDomain, link.destUri, link.destId, "", type ) ];%#ok<AGROW>
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7e4knZ.p.
% Please follow local copyright laws when handling this file.

