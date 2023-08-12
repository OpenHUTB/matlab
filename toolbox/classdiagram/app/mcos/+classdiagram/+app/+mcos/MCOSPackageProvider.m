classdef MCOSPackageProvider < mdom.BaseDataProvider
properties ( SetObservable = true )
RootCount = 0;

RootNodesMap


ElementMap

ChildrenElementMap


UUID2ObjectIDMap

ObjectID2UUIDMap


ChildrenMap

ParentMap

Factory;


WarningFcn;
end 

methods ( Static )
function ret = hasChildren( package )
metadata = meta.package.fromName( package.getName(  ) );
ret = ~isempty( metadata ) &&  ...
( ~isempty( metadata.PackageList ) || ~isempty( metadata.ClassList ) );
end 
end 

methods ( Access = private )
function success = addRootEntities( obj, entityNames )

function [ origLen, newLen ] = resortMap( indexes, type )


nodeNames = names( indexes );
origLen = length( obj.RootNodesMap( type ) );
allNodes = unique( [ obj.RootNodesMap( type ), nodeNames ] );
newLen = length( allNodes );
obj.RootNodesMap( type ) = obj.sortNames( allNodes, true );
end 

success = true;
entityNames = string( entityNames );
if ~isempty( entityNames )

names = strings( 1, length( entityNames ) );

classIndexes = false( 1, length( entityNames ) );
enumIndexes = false( 1, length( entityNames ) );
for i = 1:length( names )
names( i ) = entityNames( i );
e = obj.Factory.getClass( entityNames{ i } );
if ~isempty( e ) && ~e.isHidden(  )
classIndexes( i ) = true;
else 
e = obj.Factory.getEnum( entityNames{ i } );
if ~isempty( e ) && ~e.isHidden(  )
enumIndexes( i ) = true;
end 
end 

if ~isempty( e ) && ~e.isHidden(  )
names( i ) = e.getObjectID;
obj.ElementMap( e.getObjectID ) = e;
end 
end 
filterIndexes = or( classIndexes, enumIndexes );


invalidNames = names( ~filterIndexes );
success = isempty( invalidNames );


[ origClassLen, newClassLen ] = resortMap( classIndexes, 'Classes' );
[ origEnumLen, newEnumLen ] = resortMap( enumIndexes, 'Enums' );


obj.updateRootChildren( ( newClassLen + newEnumLen ) - ( origClassLen + origEnumLen ) );
end 
end 
end 

methods 

function obj = MCOSPackageProvider( factory, warningFcn )
obj.Factory = factory;
obj.RootNodesMap = containers.Map( { 'Packages', 'Classes', 'Enums', 'Folders', 'Projects' },  ...
{ [  ], [  ], [  ], [  ], [  ] } );

obj.ChildrenMap = containers.Map( { '_INVISIBLE_ROOT_' }, { [  ] } );
obj.ChildrenElementMap = containers.Map( { '_INVISIBLE_ROOT_' }, { [  ] } );

obj.ElementMap = containers.Map;
obj.UUID2ObjectIDMap = containers.Map;
obj.ObjectID2UUIDMap = containers.Map;
obj.ParentMap = containers.Map;
obj.WarningFcn = warningFcn;
end 




function addRootProjects( obj, projectNames, options )
R36
obj( 1, 1 );
projectNames;
options.warn( 1, 1 )logical = true;
end 

if ~isempty( projectNames )

pNames = strings( 1, length( projectNames ) );
filterIndexes = true( 1, length( projectNames ) );
for i = 1:length( projectNames )
prj = obj.Factory.getProject( projectNames{ i } );
if ~isempty( prj )
pNames( i ) = prj.getObjectID;
obj.ElementMap( prj.getObjectID ) = prj;
else 
pNames( i ) = projectNames{ i };
filterIndexes( i ) = false;
end 
end 


invalidNames = pNames( ~filterIndexes );
if ~isempty( invalidNames )
obj.issueWarning( 'ErrMInvalidMCOSObject', join( invalidNames, ',' ), options.warn );
end 



pNames = pNames( filterIndexes );
origLen = length( obj.RootNodesMap( 'Projects' ) );
allProjectNames = unique( [ obj.RootNodesMap( 'Projects' ), pNames ] );
newLen = length( allProjectNames );
obj.RootNodesMap( 'Projects' ) = obj.sortNames( allProjectNames, false );


obj.updateRootChildren( newLen - origLen );
end 
end 

function removeRootProjects( obj, projectNames )
if ~isempty( projectNames )
projects = obj.RootNodesMap( 'Projects' );
if ~isempty( projects )

removeIndexes = false( 1, length( projects ) );
for i = 1:length( projectNames )
removeIndexes = removeIndexes | arrayfun( @( x )x == "Project|" + projectNames{ i }, projects );
end 


obj.RootNodesMap( 'Projects' ) = projects( ~removeIndexes );


pUUID = "_INVISIBLE_ROOT_";
deletedNodes = projects( removeIndexes );
obj.cleanNodesUnderParent( deletedNodes, pUUID );


obj.updateRootChildren(  - length( deletedNodes ) );
end 
end 
end 


function addRootFolders( obj, folderNames, options )
R36
obj( 1, 1 );
folderNames;
options.warn( 1, 1 )logical = true;
end 

if ~isempty( folderNames )

folderNames = string( unique( cellstr( folderNames ) ) );
fNames = strings( 1, length( folderNames ) );
filterFolderIndexes = true( 1, length( folderNames ) );
for i = 1:length( folderNames )
f = obj.Factory.getFolder( folderNames{ i } );
if ~isempty( f )
fNames( i ) = f.getObjectID;
obj.ElementMap( f.getObjectID ) = f;
else 
fNames( i ) = folderNames{ i };
filterFolderIndexes( i ) = false;
end 
end 


invalidNames = folderNames( ~filterFolderIndexes );
if ~isempty( invalidNames )
obj.issueWarning( 'ErrMInvalidMCOSObject', join( invalidNames, ',' ), options.warn );
end 



fNames = fNames( filterFolderIndexes );
origLen = length( obj.RootNodesMap( 'Folders' ) );
allFolderNames = unique( [ obj.RootNodesMap( 'Folders' ), fNames ] );
newLen = length( allFolderNames );
obj.RootNodesMap( 'Folders' ) = obj.sortNames( allFolderNames, false );


obj.updateRootChildren( newLen - origLen );
end 
end 

function removeRootFolders( obj, folderNames )
if ~isempty( folderNames )
folders = obj.RootNodesMap( 'Folders' );
if ~isempty( folders )

removeFolderIndexes = false( 1, length( folders ) );
for i = 1:length( folderNames )
removeFolderIndexes = removeFolderIndexes | arrayfun( @( x )x == "Folder|" + folderNames{ i }, folders );
end 


obj.RootNodesMap( 'Folders' ) = folders( ~removeFolderIndexes );


pUUID = "_INVISIBLE_ROOT_";
deletedNodes = folders( removeFolderIndexes );
obj.cleanNodesUnderParent( deletedNodes, pUUID );


obj.updateRootChildren(  - length( deletedNodes ) );
end 
end 
end 


function success = addRootPackages( obj, packageNames, options )
R36
obj( 1, 1 );
packageNames;
options.warn( 1, 1 )logical = true;
end 
success = true;

if ~isempty( packageNames )

pkgNames = strings( 1, length( packageNames ) );
filterPkgIndexes = true( 1, length( packageNames ) );
for i = 1:length( packageNames )
p = obj.Factory.getPackage( packageNames{ i } );
if ~isempty( p )
pkgNames( i ) = p.getObjectID;
obj.ElementMap( p.getObjectID ) = p;
else 
pkgNames( i ) = packageNames( i );
filterPkgIndexes( i ) = false;
obj.issueWarning( 'ErrMInvalidMCOSPackage', packageNames{ i }, options.warn );
end 
end 


invalidNames = pkgNames( ~filterPkgIndexes );
success = isempty( invalidNames );



pkgNames = pkgNames( filterPkgIndexes );
origLen = length( obj.RootNodesMap( 'Packages' ) );
allPkgNames = unique( [ obj.RootNodesMap( 'Packages' ), pkgNames ] );
newLen = length( allPkgNames );
obj.RootNodesMap( 'Packages' ) = obj.sortNames( allPkgNames, true );


obj.updateRootChildren( newLen - origLen );
end 
end 


function removeRootPackages( obj, packageNames )
if ~isempty( packageNames )
packages = obj.RootNodesMap( 'Packages' );
if ~isempty( packages )

removePkgIndexes = false( 1, length( packages ) );
for i = 1:length( packageNames )
removePkgIndexes = removePkgIndexes | arrayfun( @( x )x == "Package|" + packageNames{ i }, packages );
end 


obj.RootNodesMap( 'Packages' ) = packages( ~removePkgIndexes );


pUUID = "_INVISIBLE_ROOT_";
deletedNodes = packages( removePkgIndexes );
obj.cleanNodesUnderParent( deletedNodes, pUUID );


obj.updateRootChildren(  - length( deletedNodes ) );
end 
end 
end 


function success = addRootClasses( obj, classNames )
success = obj.addRootEntities( classNames );
end 



function removeRootClasses( obj, classNames )
if ~isempty( classNames )
classes = obj.RootNodesMap( 'Classes' );
if ~isempty( classes )

removeClsIndexes = false( 1, length( classes ) );
for i = 1:length( classNames )
removeClsIndexes = removeClsIndexes | arrayfun( @( x )x == "Class|" + classNames{ i }, classes );
end 


obj.RootNodesMap( 'Classes' ) = classes( ~removeClsIndexes );


deletedNodes = classes( removeClsIndexes );
obj.updateRootChildren(  - length( deletedNodes ) );
end 
end 
end 


function success = addRootEnums( obj, enumNames )
success = obj.addRootEntities( enumNames );
end 


function removeRootEnums( obj, enumNames )
if ~isempty( enumNames )
enums = obj.RootNodesMap( 'Enums' );
if ~isempty( enums )

removeEnumIndexes = false( 1, length( enums ) );
for i = 1:length( enumNames )
removeEnumIndexes = removeEnumIndexes | arrayfun( @( x )x == "Enum|" + enumNames{ i }, enums );
end 


obj.RootNodesMap( 'Enums' ) = enums( ~removeEnumIndexes );


deletedNodes = enums( removeEnumIndexes );
obj.updateRootChildren(  - length( deletedNodes ) );
end 
end 
end 

function success = addRootClassOrEnum( obj, classOrEnumName, options )
R36
obj( 1, 1 );
classOrEnumName;
options.warn( 1, 1 )logical = true;
end 
success = false;
node = obj.Factory.getPackageElement( classOrEnumName );
if isempty( node )
obj.issueWarning( 'ErrMInvalidMCOSClass', classOrEnumName, options.warn );
else 
if isa( node, 'classdiagram.app.core.domain.Class' )
success = obj.addRootClasses( { classOrEnumName } );
elseif isa( node, 'classdiagram.app.core.domain.Enum' )
success = obj.addRootEnums( { classOrEnumName } );
end 
end 
end 

function removeNodeByUUID( obj, uuid )


if obj.UUID2ObjectIDMap.isKey( uuid )
pUUID = obj.ParentMap( uuid );
if pUUID == "_INVISIBLE_ROOT_"
node = obj.getElementForUUID( uuid );
name = { obj.UUID2ObjectIDMap( uuid ).extractAfter( "|" ) };
if isa( node, 'classdiagram.app.core.domain.Package' )
obj.removeRootPackages( name );
elseif isa( node, 'classdiagram.app.core.domain.Folder' )
obj.removeRootFolders( name );
elseif isa( node, 'classdiagram.app.core.domain.Project' )
obj.removeRootProjects( name );
elseif isa( node, 'classdiagram.app.core.domain.Class' )
obj.removeRootClasses( name );
elseif isa( node, 'classdiagram.app.core.domain.Enum' )
obj.removeRootEnums( name );
end 
else 
pID = obj.UUID2ObjectIDMap( pUUID );
obj.cleanNode( uuid, pUUID );
obj.updateChildren( pID, pUUID );
end 
end 
end 

function parentName = findParentInElementMap( obj, packageName )
parentName = [  ];
metadata = meta.package.fromName( packageName );
if isempty( metadata ) || isempty( metadata.ContainingPackage )
return ;
end 
parentName = metadata.ContainingPackage.Name;
if obj.ElementMap.isKey( "Package|" + parentName )
return ;
end 
parentName = obj.findParentInElementMap( parentName );
end 

function updateClass( obj, class )



if ~obj.ElementMap.isKey( class.getObjectID )
parent = class.getOwningPackage;
if ~isempty( parent ) && ~obj.ElementMap.isKey( parent.getObjectID )
parentName = obj.findParentInElementMap( parent.getName );
if isempty( parentName )
return ;
end 
parent = obj.Factory.getPackage( parentName );
end 
if isempty( parent )
return ;
end 
if obj.ElementMap.isKey( parent.getObjectID )
obj.updatePackage( parent );
if ~obj.ObjectID2UUIDMap.isKey( parent.getObjectID )
return ;
end 
pUUID = obj.ObjectID2UUIDMap( parent.getObjectID );
dm = mdom.DataModel.findDataModel( obj.DataModelID );
indexOfPackage = dm.getIndexForID( pUUID );
if ( indexOfPackage.RowIndex ~=  - 1 )
dm.rangeDataChanged( mdom.Range( indexOfPackage.ParentID, 0, indexOfPackage.RowIndex, 0, 0 ) );
end 
end 
else 
nodeUUIDs = obj.ObjectID2UUIDMap( class.getObjectID );
dm = mdom.DataModel.findDataModel( obj.DataModelID );
for i = 1:length( nodeUUIDs )
index = dm.getIndexForID( nodeUUIDs( i ) );
if ( index.RowIndex ~=  - 1 )
dm.rangeDataChanged( mdom.Range( index.ParentID, 0, index.RowIndex, 0, 0 ) );

pUUID = index.ParentID;
indexOfPackage = dm.getIndexForID( pUUID );
if ( indexOfPackage.RowIndex ~=  - 1 )
dm.rangeDataChanged( mdom.Range( indexOfPackage.ParentID, 0, indexOfPackage.RowIndex, 0, 0 ) );
end 
end 
end 
end 
end 

function updatePackage( obj, pkg )
if ( obj.ElementMap.isKey( pkg.getObjectID ) )

dm = mdom.DataModel.findDataModel( obj.DataModelID );
dm.refreshView;
end 
end 

function refreshHierarchy( obj )
import classdiagram.app.core.domain.*;


obj.refreshRootLevelNodes(  );

rootNodes = obj.ChildrenElementMap( '_INVISIBLE_ROOT_' );
for n = rootNodes
node = obj.ElementMap( n );
if ~isa( node, 'Class' ) && ~isa( node, 'Enum' )
obj.refreshSubHierarchy( node );
end 
end 
end 


function requestData( obj, ev )
import classdiagram.app.core.domain.*;


rowList = ev.RowInfoRequests;
rowInfo = mdom.RowInfo( rowList );
pID = '';
rowMetaList = {  };
for r = 1:length( rowList )
rIndex = rowList( r );
rowPID = rIndex.ParentID;
if ~strcmp( pID, rowPID )
rowMetaList = obj.ChildrenMap( rowPID );
pID = rowPID;
end 
if isempty( rowMetaList )

return ;
end 

if rIndex.RowIndex + 1 <= rowMetaList.length
rowUUID = rowMetaList( rIndex.RowIndex + 1 );
element = obj.getElementForUUID( rowUUID );
rowInfo.setRowID( rIndex, rowUUID );

dm = mdom.DataModel.findDataModel( obj.DataModelID );
if dm.isRowExpanded( dm.getIDForIndex( rIndex ) )
rowInfo.setRowExpanded( rIndex, true );
rowInfo.setRowHasChild( rIndex, mdom.HasChild.YES );
elseif element.getState ~= ElementState.Stale
if isa( element, 'Package' )
if obj.hasChildren( element )
rowInfo.setRowHasChild( rIndex, mdom.HasChild.MAYBE );
end 
elseif isa( element, 'Folder' ) || isa( element, 'Project' )
if element.hasChild
rowInfo.setRowHasChild( rIndex, mdom.HasChild.MAYBE );
end 
end 
end 
end 
end 
ev.addRowInfo( rowInfo );


colList = ev.ColumnInfoRequests;
colInfo = mdom.ColumnInfo( colList );
for c = 1:length( colList )
meta = mdom.MetaData;
meta.setProp( 'label', 'Classes' );
meta.setProp( 'renderer', 'CBRenderer' );
widthMeta = mdom.MetaData;
widthMeta.setProp( 'unit', '%' );
widthMeta.setProp( 'value', 100 );
meta.setProp( 'width', widthMeta );
colInfo.fillMetaData( colList( c ), meta );
end 

ev.addColumnInfo( colInfo );


ranges = ev.RangeRequests;
mdom.Data.registerDataType( 'incanvas', mdom.DataType.INT );
mdom.Data.registerDataType( 'notonpath', mdom.DataType.BOOL );
mdom.Data.registerDataType( 'uuid', mdom.DataType.STRING );
data = mdom.Data;
showDetails = obj.Factory.GlobalSettingsFcn( 'ShowDetails' );
for i = 1:length( ranges )
rangeData = mdom.RangeData( ranges( i ) );
rowPID = ranges( i ).ParentID;
if ~strcmp( pID, rowPID )
if ~obj.ChildrenMap.isKey( rowPID )

return ;
end 
rowMetaList = obj.ChildrenMap( rowPID );
pID = rowPID;
end 

for r = ranges( i ).RowStart:ranges( i ).RowEnd
if r + 1 <= rowMetaList.length
for c = ranges( i ).ColumnStart:ranges( i ).ColumnEnd
uuid = rowMetaList( r + 1 );
element = obj.getElementForUUID( uuid );
data.clear(  );
s = split( element.getName(  ), '.' );
data.setProp( 'label', s{ length( s ) } );
if isa( element, 'Package' )
data.setProp( 'iconUri', 'editor-ui/images/package_16.png' );
elseif isa( element, 'Folder' )
s = split( element.getName(  ), filesep );
data.setProp( 'label', s{ length( s ) } );
data.setProp( 'iconUri', 'editor-ui/images/folder_16.png' );
elseif isa( element, 'Project' )
[ ~, name, ~ ] = fileparts( element.getName(  ) );
data.setProp( 'label', name );
data.setProp( 'iconUri', 'editor-ui/images/project_16.png' );
elseif isa( element, 'Class' )
data.setProp( 'iconUri', 'editor-ui/images/class_16.png' );
else 
data.setProp( 'iconUri', 'editor-ui/images/enumeration_16.png' );
end 
data.setProp( 'id', element.getObjectID(  ) );
data.setProp( 'uuid', uuid );


if ~showDetails && classdiagram.app.core.InheritanceFlags.isMixin( element )
data.setProp( 'incanvas', 1 );
elseif isa( element, 'Package' ) &&  ...
( ~obj.hasChildren( element ) ||  ...
~Package.hasPackageElements( element ) )

data.setProp( 'incanvas', 1 );
else 
data.setProp( 'incanvas', 2 * obj.Factory.isObjectInDiagram( element ) );
end 


stale = element.getState == ElementState.Stale;
data.setProp( 'notonpath', ~obj.Factory.isObjectOnPath( element ) || stale );

rangeData.fillData( r, c, data );
end 
end 
end 
ev.addRangeData( rangeData );
end 

ev.send(  );
end 

function onExpand( obj, uuid )
if ~isempty( uuid )
dm = mdom.DataModel.findDataModel( obj.DataModelID );

if ~obj.ChildrenMap.isKey( uuid )
obj.populateChildren( uuid );
end 

dm.rowChanged( uuid, length( obj.ChildrenMap( uuid ) ), {  } );


obj.expandSubNodesIfNeeded( uuid )
end 
end 

function onCollapse( obj, uuid )
if ~isempty( uuid )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
dm.rowChanged( uuid, 0, {  } );
end 
end 

function onCollapseAll( obj )
rootNodesUUID = obj.getRootNodesUUID(  );
for i = 1:length( rootNodesUUID )
obj.collapseNodeByUUID( rootNodesUUID( i ) );
end 
end 

end 

methods ( Hidden = true )
function topnodes = getRootNodes( obj )
topnodes = arrayfun( @( n )obj.ID2Node( n ), obj.ChildrenElementMap( '_INVISIBLE_ROOT_' ), 'uni', false );
end 


function topnodes = getRootNodesUUID( obj )
topnodes = obj.getChildNodesUUID( '_INVISIBLE_ROOT_' );
end 

function childnodes = getChildNodes( obj, parentNode )
childnodes = [  ];
if isa( parentNode, 'classdiagram.app.core.domain.BaseObject' ) &&  ...
obj.ChildrenElementMap.isKey( parentNode.getObjectID )
childnodes = arrayfun( @( n )obj.ID2Node( n ), obj.ChildrenElementMap( parentNode.getObjectID ), 'UniformOutput', false );
end 
end 

function childnodes = getChildNodesUUID( obj, pUUID )
childnodes = [  ];
if obj.ChildrenMap.isKey( pUUID )
childnodes = obj.ChildrenMap( pUUID );
end 
end 

function nodeInfo = getNodeInfoByID( obj, nodeID )
nodeInfo = struct(  );
if obj.ObjectID2UUIDMap.isKey( nodeID )
uuids = obj.ObjectID2UUIDMap( nodeID );
nodeInfo = arrayfun( @( uuid )obj.getNodeInfo( uuid ), uuids, 'uni', 0 );
end 
end 

function nodeInfo = getNodeInfo( obj, uuid )
import classdiagram.app.core.domain.*;

nodeInfo = struct(  );
if obj.UUID2ObjectIDMap.isKey( uuid )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
nodeID = obj.UUID2ObjectIDMap( uuid );
node = obj.ElementMap( nodeID );

nodeInfo.ID = nodeID;


nodeInfo.Expanded = dm.isRowExpanded( uuid );
nodeInfo.Expandable = false;
if node.getState ~= ElementState.Stale
if isa( node, 'Package' )
if obj.hasChildren( node )
nodeInfo.Expandable = true;
end 
elseif isa( node, 'Folder' ) || isa( node, 'Project' )
if node.hasChild
nodeInfo.Expandable = true;
end 
end 
end 


if isa( node, 'Package' )
nodeInfo.icon = 'editor-ui/images/package_16.png';
elseif isa( node, 'Class' )
nodeInfo.icon = 'editor-ui/images/class_16.png';
elseif isa( node, 'Enum' )
nodeInfo.icon = 'editor-ui/images/enumeration_16.png';
elseif isa( node, 'Project' )
nodeInfo.icon = 'editor-ui/images/project_16.png';
elseif isa( node, 'Folder' )
nodeInfo.icon = 'editor-ui/images/folder_16.png';
end 

if ~obj.Factory.GlobalSettingsFcn( 'ShowDetails' ) && classdiagram.app.core.InheritanceFlags.isMixin( node )
nodeInfo.InCanvas = 1;
elseif isa( node, 'Package' ) &&  ...
( ~obj.hasChildren( node ) ||  ...
~Package.hasPackageElements( node ) )

nodeInfo.InCanvas = 1;
else 
nodeInfo.InCanvas = 2 * obj.Factory.isObjectInDiagram( node );
end 


stale = node.getState == ElementState.Stale;
nodeInfo.NotOnPath = ~obj.Factory.isObjectOnPath( node ) || stale;
end 
end 

function expandNode( obj, node )
if isa( node, 'classdiagram.app.core.domain.BaseObject' )
if obj.ObjectID2UUIDMap.isKey( node.getObjectID )
uuids = obj.ObjectID2UUIDMap( node.getObjectID );
for i = 1:length( uuids )
obj.expandNodeByUUID( uuids( i ) );
end 
end 
end 
end 

function expandNodeByUUID( obj, uuid )
if obj.UUID2ObjectIDMap.isKey( uuid )
nodeID = obj.UUID2ObjectIDMap( uuid );
node = obj.ElementMap( nodeID );
if isa( node, 'classdiagram.app.core.domain.BaseObject' )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
if ~dm.isRowExpanded( uuid )
obj.onExpand( uuid );
end 
end 
end 
end 

function collapseNode( obj, node )
if isa( node, 'classdiagram.app.core.domain.BaseObject' )
if obj.ObjectID2UUIDMap.isKey( node.getObjectID )
uuids = obj.ObjectID2UUIDMap( node.getObjectID );
for i = 1:length( uuids )
obj.collapseNodeByUUID( uuids( i ) );
end 
end 
end 
end 

function collapseNodeByUUID( obj, uuid )
if obj.UUID2ObjectIDMap.isKey( uuid )
nodeID = obj.UUID2ObjectIDMap( uuid );
node = obj.ElementMap( nodeID );
if isa( node, 'classdiagram.app.core.domain.BaseObject' )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
if dm.isRowExpanded( uuid )
obj.onCollapse( uuid );
end 
end 
end 
end 
end 


methods ( Access = private )
function sortedNames = sortNames( obj, names, sortNameOnly )
sortedNames = string.empty;
if ~isempty( names )
if sortNameOnly
shortNames = arrayfun( @( n )obj.getShortName( n ), names );
namesMatrix = sortrows( [ upper( shortNames );names ]' );
else 
namesMatrix = sortrows( [ upper( names );names ]' );
end 

sortedNames = namesMatrix( :, 2 )';
end 
end 

function shortName = getShortName( ~, name )
arr = split( name, '|' );
arr = split( arr( end  ), '.' );
shortName = arr( end  );
end 

function node = ID2Node( obj, id )
if obj.ElementMap.isKey( id )
node = obj.ElementMap( id );
end 
end 

function updateRootChildren( obj, newCount )
if newCount ~= 0
pUUID = "_INVISIBLE_ROOT_";
obj.ChildrenElementMap( pUUID ) = [ obj.RootNodesMap( 'Projects' ), obj.RootNodesMap( 'Folders' ), obj.RootNodesMap( 'Packages' ),  ...
obj.RootNodesMap( 'Classes' ), obj.RootNodesMap( 'Enums' ) ];

obj.RootCount = obj.RootCount + newCount;

obj.updateChildren( pUUID, pUUID );
end 
end 

function updateChildren( obj, pID, pUUID )

dm = mdom.DataModel.findDataModel( obj.DataModelID );
childCount = length( obj.ChildrenElementMap( pID ) );
dm.rowChanged( pUUID, childCount, {  } );



newUUIDs = strings( 1, childCount );

allRoots = obj.ChildrenElementMap( pID );
for i = 1:childCount
nodeObjectID = allRoots( i );
if ~obj.ObjectID2UUIDMap.isKey( nodeObjectID )

nodeUUID = matlab.lang.internal.uuid;
obj.ObjectID2UUIDMap( nodeObjectID ) = nodeUUID;
else 
nodeUUID = obj.getUUIDUnderParent( nodeObjectID, pUUID );
if isempty( nodeUUID )
nodeUUID = matlab.lang.internal.uuid;
obj.ObjectID2UUIDMap( nodeObjectID ) = [ obj.ObjectID2UUIDMap( nodeObjectID ), nodeUUID ];
else 
if dm.isRowExpanded( nodeUUID )

dm.updateRowID( mdom.RowIndex( pUUID, i - 1 ), nodeUUID );
end 
end 
end 

obj.UUID2ObjectIDMap( nodeUUID ) = nodeObjectID;
obj.ParentMap( nodeUUID ) = pUUID;
newUUIDs( i ) = nodeUUID;
end 
obj.ChildrenMap( pUUID ) = newUUIDs;
end 

function populateChildren( obj, uuid )

import classdiagram.app.core.domain.*;

if obj.UUID2ObjectIDMap.isKey( uuid )
id = obj.UUID2ObjectIDMap( uuid );
if ~obj.ChildrenElementMap.isKey( id )
e = obj.ElementMap( id );
if isa( e, 'Package' )
obj.populatePackage( e );
elseif isa( e, 'Folder' ) || isa( e, 'Project' )
obj.populateFolderOrProject( e );
end 
end 
obj.updateChildren( id, uuid );
end 
end 

function populateFolderOrProject( obj, f )
import classdiagram.app.core.domain.ElementState;

id = f.getObjectID;


folders = obj.Factory.getSubFolders( f );
folderNames = strings( 1, length( folders ) );
for i = 1:length( folders )
folderNames( i ) = folders( i ).getObjectID;
obj.ElementMap( folderNames( i ) ) = folders( i );
end 

folderNames = obj.sortNames( folderNames, false );


[ classNames, enumNames ] = f.getClassFullNames(  );
classes = strings( 1, length( classNames ) );
filterClassIndexes = true( 1, length( classNames ) );
for i = 1:length( classes )
c = obj.Factory.getDomainObject( classNames{ i } );
if isempty( c )
c = obj.Factory.getPlaceholderClass( classNames{ i },  ...
ElementState.NotOnPath );
end 
if c.isHidden(  )
filterClassIndexes( i ) = false;
else 
classes( i ) = c.getObjectID;
obj.ElementMap( c.getObjectID ) = c;
end 
end 

classNames = classes( filterClassIndexes );

enums = strings( 1, length( enumNames ) );
filterEnumIndexes = true( 1, length( enumNames ) );
for i = 1:length( enums )
ec = obj.Factory.getDomainObject( enumNames{ i } );
if isempty( ec )
ec = obj.Factory.getPlaceholderClass( enumNames{ i },  ...
ElementState.NotOnPath );
end 
if ec.isHidden(  )
filterEnumIndexes( i ) = false;
else 
enums( i ) = ec.getObjectID;
obj.ElementMap( ec.getObjectID ) = ec;
end 
end 

enumNames = enums( filterEnumIndexes );


classNames = obj.sortNames( classNames, true );
enumNames = obj.sortNames( enumNames, true );

obj.ChildrenElementMap( id ) = [ folderNames, classNames, enumNames ];


obj.Factory.updateParentChildMaps( f, folders );
obj.Factory.updateParentChildMaps( f, arrayfun( @( n )obj.ElementMap( n ), classNames ) );
obj.Factory.updateParentChildMaps( f, arrayfun( @( n )obj.ElementMap( n ), enumNames ) );
end 

function populatePackage( obj, p )
id = p.getObjectID;
pkgs = obj.Factory.getSubPackages( p );
classes = obj.Factory.getClasses( p );
enums = obj.Factory.getEnums( p );

pkgNames = strings( 1, length( pkgs ) );
for i = 1:length( pkgs )
pkgNames( i ) = pkgs( i ).getObjectID;
obj.ElementMap( pkgNames( i ) ) = pkgs( i );
end 

pkgNames = obj.sortNames( pkgNames, true );

classNames = strings( 1, length( classes ) );
filterClassIndexes = true( 1, length( classes ) );
for j = 1:length( classes )
classNames( j ) = classes( j ).getObjectID;
if ~classes( j ).isHidden(  )
obj.ElementMap( classNames( j ) ) = classes( j );
else 
filterClassIndexes( j ) = false;
end 
end 

filterClassNames = classNames( filterClassIndexes );
filterClassNames = obj.sortNames( filterClassNames, true );

enumNames = strings( 1, length( enums ) );
filterEnumIndexes = true( 1, length( enums ) );
for k = 1:length( enums )
enumNames( k ) = enums( k ).getObjectID;
if ~enums( k ).isHidden(  )
obj.ElementMap( enumNames( k ) ) = enums( k );
else 
filterEnumIndexes( k ) = false;
end 
end 

filterEnumNames = enumNames( filterEnumIndexes );
filterEnumNames = obj.sortNames( filterEnumNames, true );

obj.ChildrenElementMap( id ) = [ pkgNames, filterClassNames, filterEnumNames ];
end 

function expandSubNodesIfNeeded( obj, pUUID )
if obj.ChildrenMap.isKey( pUUID )
childrenList = obj.ChildrenMap( pUUID );
dm = mdom.DataModel.findDataModel( obj.DataModelID );
for k = 1:length( childrenList )
uuid = childrenList( k );
id = obj.UUID2ObjectIDMap( uuid );
element = obj.ElementMap( id );
if ~isa( element, 'classdiagram.app.core.domain.PackageElement' )
if ( dm.isRowExpanded( uuid ) )

dm.updateRowID( mdom.RowIndex( pUUID, k - 1 ), uuid );
dm.rowChanged( uuid, length( obj.ChildrenMap( uuid ) ), {  } );

obj.expandSubNodesIfNeeded( uuid );
end 
end 
end 
end 
end 

function isParentNode = isParentNode( obj, cUUID, pUUID )
isParentNode = false;
if obj.ParentMap.isKey( cUUID )
isParentNode = obj.ParentMap( cUUID ) == pUUID;
end 
end 

function UUID = getUUIDUnderParent( obj, ObjectID, pUUID )
UUID = [  ];
if obj.ObjectID2UUIDMap.isKey( ObjectID )
refNodeUUIDs = obj.ObjectID2UUIDMap( ObjectID );
for i = 1:length( refNodeUUIDs )
if obj.isParentNode( refNodeUUIDs( i ), pUUID )
UUID = refNodeUUIDs( i );
return ;
end 
end 
end 
end 

function element = getElementForUUID( obj, uuid )
element = '';
if obj.UUID2ObjectIDMap.isKey( uuid )
objectID = obj.UUID2ObjectIDMap( uuid );
if obj.ElementMap.isKey( objectID )
element = obj.ElementMap( obj.UUID2ObjectIDMap( uuid ) );
else 
element = objectID;
end 
end 
end 

function cleanNodesUnderParent( obj, deletedNodes, pUUID )
for i = 1:length( deletedNodes )
nodeUUID = obj.getUUIDUnderParent( deletedNodes( i ), pUUID );
obj.cleanNode( nodeUUID, pUUID );
end 
end 

function cleanNode( obj, nodeUUID, pUUID )
if ~isempty( nodeUUID )
nodeObjectID = obj.UUID2ObjectIDMap( nodeUUID );

if obj.ChildrenMap.isKey( nodeUUID )
childrenList = obj.ChildrenMap( nodeUUID );
for i = 1:length( childrenList )
uuid = childrenList( i );
obj.cleanNode( uuid, nodeUUID );
end 
obj.ChildrenMap.remove( nodeUUID );
dm = mdom.DataModel.findDataModel( obj.DataModelID );
dm.rowChanged( nodeUUID, 0, {  } );
end 

obj.ParentMap.remove( nodeUUID );
obj.UUID2ObjectIDMap.remove( nodeUUID );
nodeArrays = obj.ObjectID2UUIDMap( nodeObjectID );
nodeArrays = nodeArrays( nodeArrays ~= nodeUUID );
if isempty( nodeArrays )
obj.ObjectID2UUIDMap.remove( nodeObjectID );
if pUUID ~= "_INVISIBLE_ROOT_"

obj.ElementMap.remove( nodeObjectID );
end 
end 

if obj.ChildrenElementMap.isKey( nodeObjectID )
if isempty( nodeArrays ) || isempty( obj.ChildrenElementMap( nodeObjectID ) )
obj.ChildrenElementMap.remove( nodeObjectID );
end 
end 
end 
end 

function refreshRootLevelNodes( obj )
import classdiagram.app.core.domain.ElementState;

pID = "_INVISIBLE_ROOT_";
rootNodes = obj.ChildrenElementMap( pID );
validIndex = true( 1, length( rootNodes ) );
for i = 1:length( rootNodes )
node = obj.ElementMap( rootNodes( i ) );
newNode = obj.Factory.retrieveNonCachedObject( node );
if isempty( newNode )
node.setState( ElementState.Stale );
validIndex( i ) = false;
else 
node.setState( newNode.getState );
if newNode.getState == ElementState.Stale
validIndex( i ) = false;
end 
end 
end 


removeNodes = rootNodes( ~validIndex );
obj.cleanNodesUnderParent( removeNodes, pID );
obj.updateChildren( pID, pID );
end 

function refreshSubHierarchy( obj, pNode )
pID = pNode.getObjectID;
if obj.ChildrenElementMap.isKey( pID )

[ oldParentNodeIDs, oldClasseIDs, oldEnumIDs ] = obj.getGroupedChildNodeIDs( pNode );


newNodes = obj.Factory.retrieveNonCachedChildren( pNode );
newParentNodeIDs = obj.getNodeIDs( newNodes{ 1 } );
newClasseIDs = obj.getNodeIDs( newNodes{ 2 } );
newEnumIDs = obj.getNodeIDs( newNodes{ 3 } );


removedParentNodeIDs = setdiff( oldParentNodeIDs, newParentNodeIDs );
removedClasseIDs = setdiff( oldClasseIDs, newClasseIDs );
removedEnumIDs = setdiff( oldEnumIDs, newEnumIDs );


pUUIDs = obj.ObjectID2UUIDMap( pID );
for uuid = pUUIDs
obj.cleanNodesUnderParent( removedParentNodeIDs, uuid );
obj.cleanNodesUnderParent( removedClasseIDs, uuid );
obj.cleanNodesUnderParent( removedEnumIDs, uuid );
end 


for i = 1:length( newNodes )
nodes = newNodes{ i };
for j = 1:length( nodes )
n = nodes( j );
if obj.ElementMap.isKey( n.getObjectID )
o = obj.ElementMap( n.getObjectID );
o.setState( n.getState );
else 
obj.ElementMap( n.getObjectID ) = n;
end 
end 
end 


newParentNodeIDs = obj.sortNames( newParentNodeIDs, true );
newClasseIDs = obj.sortNames( newClasseIDs, true );
newEnumIDs = obj.sortNames( newEnumIDs, true );

obj.ChildrenElementMap( pID ) = [ newParentNodeIDs, newClasseIDs, newEnumIDs ];

dm = mdom.DataModel.findDataModel( obj.DataModelID );
for uuid = pUUIDs
if dm.isRowExpanded( uuid )
obj.updateChildren( pID, uuid );
end 
end 



remainingParentNodeIDs = intersect( oldParentNodeIDs, newParentNodeIDs );
arrayfun( @( id )obj.refreshSubHierarchy( obj.ElementMap( id ) ), remainingParentNodeIDs );




obj.cleanChildParentMapEntries( pUUIDs );
else 



classdiagram.app.core.commands.ClassDiagramRefreshCommand.updateStateForChildren(  ...
obj.Factory, pNode );
end 
end 

function cleanChildParentMapEntries( obj, uuids )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
for uuid = uuids
if ~dm.isRowExpanded( uuid ) && obj.ChildrenMap.isKey( uuid )
childrenList = obj.ChildrenMap( uuid );
for cuuid = childrenList
if obj.ParentMap.isKey( cuuid )
obj.ParentMap.remove( cuuid );
end 

if obj.UUID2ObjectIDMap.isKey( cuuid )
nodeObjectID = obj.UUID2ObjectIDMap( cuuid );
obj.UUID2ObjectIDMap.remove( cuuid );

if obj.ObjectID2UUIDMap.isKey( nodeObjectID )
nodeArrays = obj.ObjectID2UUIDMap( nodeObjectID );
obj.ObjectID2UUIDMap( nodeObjectID ) = nodeArrays( nodeArrays ~= cuuid );
end 
end 
end 
obj.ChildrenMap.remove( uuid );
end 
end 
end 

function [ nonLeafNodes, classes, enums ] = getGroupedChildNodeIDs( obj, pNode )
oldNodes = obj.ChildrenElementMap( pNode.getObjectID );
nonLeafIndex = false( 1, length( oldNodes ) );
classIndex = false( 1, length( oldNodes ) );
enumIndex = false( 1, length( oldNodes ) );

nodes = arrayfun( @( n )obj.ElementMap( n ), oldNodes, 'uni', false );

for i = 1:length( nodes )
node = nodes{ i };
if isa( node, "classdiagram.app.core.domain.Class" )
classIndex( i ) = true;
elseif isa( node, "classdiagram.app.core.domain.Enum" )
enumIndex( i ) = true;
else 
nonLeafIndex( i ) = true;
end 
end 

nonLeafNodes = oldNodes( nonLeafIndex );
classes = oldNodes( classIndex );
enums = oldNodes( enumIndex );
end 

function nodeNames = getNodeIDs( ~, nodes )
nodeNames = strings( 1, 0 );
if ~isempty( nodes )
nodeNames = strings( 1, length( nodes ) );
for i = 1:length( nodes )
nodeNames( i ) = nodes( i ).getObjectID;
end 
end 
end 

function issueWarning( obj, id, messageFills, warn )
if ~warn
return ;
end 
if classdiagram.app.core.feature.isOn( 'notifications' )
notifObj = classdiagram.app.core.notifications.notifications.( id )(  ...
messageFills );
obj.WarningFcn( notifObj );
else 
obj.WarningFcn( id, messageFills );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpYyW2Ou.p.
% Please follow local copyright laws when handling this file.

