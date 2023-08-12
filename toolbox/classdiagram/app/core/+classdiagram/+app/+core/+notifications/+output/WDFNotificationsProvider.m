classdef WDFNotificationsProvider < mdom.BaseDataProvider
properties ( SetObservable = true )
RootCount = 0;


uuid2ObjMap;

ChildrenMap;
HistoryMap;

CleanUpRules;


channel;
end 

properties ( Constant )
Root = '_INVISIBLE_ROOT_';
TotalsType = "NotificationTotals";
end 

methods 
function obj = WDFNotificationsProvider( channelId )
obj.channel = channelId;

obj.uuid2ObjMap = containers.Map;
obj.ChildrenMap = containers.Map;
obj.HistoryMap = containers.Map;


obj.ChildrenMap( obj.Root ) = [  ];
obj.HistoryMap( obj.Root ) = [  ];


obj.RootCount = length( obj.ChildrenMap( obj.Root ) );
end 

function setCleanUpRules( obj, rules )
R36
obj( 1, 1 )classdiagram.app.core.notifications.output.WDFNotificationsProvider;
rules( 1, 1 )classdiagram.app.core.notifications.CleanUpRules;
end 
obj.CleanUpRules = rules;
end 

function requestData( obj, ev )



rowList = ev.RowInfoRequests;
rowInfo = mdom.RowInfo( rowList );
pID = '';
rowMetaList = {  };
for r = 1:length( rowList )
rIndex = rowList( r );
if rIndex.RowIndex ==  - 1
continue ;
end 
rowPID = rIndex.ParentID;

if ~strcmp( pID, rowPID )
rowMetaList = obj.ChildrenMap( rowPID );
pID = rowPID;
end 

if isempty( rowMetaList )
return ;
end 

if rIndex.RowIndex + 1 <= rowMetaList.length
uuid = rowMetaList( rIndex.RowIndex + 1 );
rowInfo.setRowID( rIndex, uuid );
currObj = obj.uuid2ObjMap( uuid );
if isa( currObj, 'cell' ) && numel( currObj ) == 1
currObj = currObj{ : };
end 

dm = obj.getDataModel;
if dm.isRowExpanded( dm.getIDForIndex( rIndex ) )
rowInfo.setRowExpanded( rIndex, true );
rowInfo.setRowHasChild( rIndex, mdom.HasChild.YES );
elseif isa( currObj, 'struct' ) ||  ...
isa( currObj, 'classdiagram.app.core.notifications.notifications.AbstractNotification' ) ...
 || strcmpi( pID, obj.Root )
rowInfo.setRowHasChild( rIndex, mdom.HasChild.MAYBE );
end 
end 
end 
ev.addRowInfo( rowInfo );


colList = ev.ColumnInfoRequests;
colInfo = mdom.ColumnInfo( colList );
for c = 1:length( colList )
meta = mdom.MetaData;
meta.setProp( 'label', 'Notifications' );
meta.setProp( 'renderer', 'DDVRenderer' );
widthMeta = mdom.MetaData;
widthMeta.setProp( 'unit', '%' );
widthMeta.setProp( 'value', 100 );
meta.setProp( 'width', widthMeta );
colInfo.fillMetaData( colList( c ), meta );
end 

ev.addColumnInfo( colInfo );


ranges = ev.RangeRequests;
data = mdom.Data;
for i = 1:length( ranges )
rangeData = mdom.RangeData( ranges( i ) );
rowPID = ranges( i ).ParentID;
if strcmp( rowPID, '' )
continue ;
end 
if ~strcmp( pID, rowPID )
if ~obj.ChildrenMap.isKey( rowPID )
return ;
end 
rowMetaList = obj.ChildrenMap( rowPID );
pID = rowPID;
end 

if isempty( rowMetaList )
return ;
end 

for r = ranges( i ).RowStart:ranges( i ).RowEnd
a =  - 1;
if ranges( i ).RowStart == a
continue ;
end 

if r + 1 <= rowMetaList.length
for c = ranges( i ).ColumnStart:ranges( i ).ColumnEnd
uuid = rowMetaList( r + 1 );
currObj = obj.uuid2ObjMap( uuid );
if isa( currObj, 'cell' )
currObj = currObj{ 1 };
end 
data.clear(  );
data.setProp( 'id', uuid );
if isa( currObj, 'struct' )
data.setProp( 'label', currObj.actionDisplayName );
elseif isa( currObj, 'classdiagram.app.core.notifications.notifications.AbstractNotification' )
data.setProp( 'label', currObj.DisplayMessage );
switch ( currObj.Severity )
case classdiagram.app.core.notifications.Severity.Error
data.setProp( 'iconUri', 'editor-ui/images/errorRound.svg' );
case classdiagram.app.core.notifications.Severity.Warning
data.setProp( 'iconUri', 'editor-ui/images/warning.svg' );
case classdiagram.app.core.notifications.Severity.Info
data.setProp( 'iconUri', 'editor-ui/images/info.svg' );
end 
else 
data.setProp( 'label', currObj );
end 

rangeData.fillData( r, c, data );
end 
end 
end 
ev.addRangeData( rangeData );
end 

ev.send(  );
end 

function onExpand( obj, id )
if ~isempty( id )
dm = obj.getDataModel;
dm.rowChanged( id, length( obj.ChildrenMap( id ) ), {  } );


obj.expandSubNodesIfNeeded( id );
end 
end 

function onCollapse( obj, id )
if ~isempty( id )
dm = obj.getDataModel;
dm.rowChanged( id, 0, {  } );
end 
end 

function refreshHierarchy( obj )
obj.refreshSubHierarchy( obj.Root );
obj.issueTotals;
end 


function clear( obj )
obj.archiveCurrentRoots(  );
if isempty( obj.CleanUpRules )
obj.deleteAll;
return ;
end 
options = struct.empty;
[ keep, remove ] = obj.CleanUpRules.applyRules( options );
if ~isempty( remove )
obj.removeNotification( categories = remove );
end 
if ~isempty( keep )
obj.removeNotification( categories = keep, not = true );
end 
obj.refreshHierarchy(  );
end 


function setNewRoots( obj, action, notifSet, targetVSet )
import classdiagram.app.core.notifications.mapUtils;

function entry = makeMapReady( entry )










if ~isa( entry, 'cell' ) && ~isscalar( entry )
entry = num2cell( entry );
end 
end 


obj.clear(  );
if isempty( notifSet ) && isempty( targetVSet )
return ;
end 
notifUuids = arrayfun( @( n )n.Uuid, notifSet );


tempUuid2ObjMap = containers.Map( notifUuids, makeMapReady( notifSet ) );
tempUuid2ObjMap( action.actionUuid ) = action;
function targetUuid = getTargetUuid( target )
targetUuid = target;
if strcmpi( target, 'Diagram' )
targetUuid = matlab.lang.internal.uuid;
end 
targetUuid = string( targetUuid );
tempUuid2ObjMap( targetUuid ) = target;
end 
targetUuids = arrayfun( @( t )getTargetUuid( t ), targetVSet );
obj.uuid2ObjMap = mapUtils.mergeMaps( obj.uuid2ObjMap, tempUuid2ObjMap );




tempChildrenMap = containers.Map( notifUuids, makeMapReady( targetUuids ), 'UniformValues', false );
tempChildrenMap( action.actionUuid ) = notifUuids;
tempChildrenMap( obj.Root ) = action.actionUuid;
obj.ChildrenMap = mapUtils.mergeMaps( obj.ChildrenMap, tempChildrenMap );

obj.refreshHierarchy(  );
end 

function removeNotification( obj, options )
R36
obj( 1, 1 );
options.categories( 1, : )string;
options.not( 1, 1 )logical = false;
options.uuids( 1, : )string;
end 
if isfield( options, 'uuids' ) && ~isempty( options.uuids )
obj.deleteByUuid( options.uuids );
return ;
end 
if ~isfield( options, 'categories' ) || isempty( options.categories )
obj.deleteAll;
return ;
end 
allNotifObjs = obj.getNotifObjs(  );
if isempty( allNotifObjs )
return ;
end 
toRemove = options.categories;
notifValues = arrayfun( @( n )string( class( n ) ), allNotifObjs );
if isa( notifValues, 'cell' )
notifValues = [ notifValues{ : } ];
end 
if isfield( options, 'not' ) && options.not
idx = ~ismember( notifValues, toRemove );
else 
idx = ismember( notifValues, toRemove );
end 
removeNotifs = allNotifObjs( idx );
obj.deleteByUuid( { removeNotifs.Uuid } );
end 

function notifObjs = getNotifObjs( obj )
allObjs = values( obj.uuid2ObjMap );
idx = cellfun( @( obj )classdiagram.app.core.notifications.output.WDFNotificationsProvider.isNotifObj(  ...
obj ), allObjs );
allObjs( ~idx ) = [  ];
notifObjs = [ allObjs{ : } ];
if isa( notifObjs, 'cell' )
notifObjs = [ notifObjs{ : } ];
end 
end 
end 


methods ( Access = private )
function refreshSubHierarchy( obj, pID )
if obj.ChildrenMap.isKey( pID )
nodes = obj.ChildrenMap( pID );

dm = obj.getDataModel;
dm.rowChanged( pID, length( nodes ), {  } );
obj.updateRowChildrenIds( pID );
arrayfun( @( id )obj.refreshSubHierarchy( id ), nodes );
end 
end 

function dm = getDataModel( obj )
dm = mdom.DataModel.findDataModel( obj.DataModelID );
end 

function updateRowChildrenIds( obj, parentNode )



dm = obj.getDataModel;
children = obj.ChildrenMap( parentNode );
for i = 1:length( children )
child = children( i );
if isa( child, 'cell' )
child = children{ i };
end 
dm.updateRowID( mdom.RowIndex( parentNode, i - 1 ), child );
end 
end 

function archiveCurrentRoots( obj )




rootValsAdd = obj.ChildrenMap( obj.Root );
if isempty( rootValsAdd )
return ;
end 
obj.HistoryMap( obj.Root ) = unique( [ obj.HistoryMap( obj.Root ), rootValsAdd ] );

keySet = keys( obj.HistoryMap );
valueSet = values( obj.HistoryMap );

keySetAdd = keys( obj.ChildrenMap );
valueSetAdd = values( obj.ChildrenMap );

notRootIdx = ~ismember( keySetAdd, obj.Root );
keySet{ end  + 1 } = keySetAdd( notRootIdx );
keySet = horzcat( keySet{ : } );
vsa = valueSetAdd( notRootIdx );
valueSet( end  + 1:end  + numel( vsa ) ) = vsa;
obj.HistoryMap = containers.Map( keySet, valueSet, 'UniformValues', false );
end 

function expandSubNodesIfNeeded( obj, id )
children = obj.ChildrenMap( id );
dm = obj.getDataModel;
for k = 1:length( children )
node = children( k );
if ~obj.uuid2ObjMap.isKey( node )



return ;
end 
if dm.isRowExpanded( node )

dm.updateRowID( mdom.RowIndex( id, k - 1 ), node );

dm.rowChanged( node, length( obj.ChildrenMap( node ) ), {  } );

obj.expandSubNodesIfNeeded( node );
end 
end 
end 

function handleDelete( obj, delChildId )
dm = obj.getDataModel;
rowIndex = dm.getIndexForID( delChildId );
if rowIndex.RowIndex ~=  - 1
parentId = rowIndex.ParentID;
end 
children = obj.ChildrenMap( parentId );
children( children == delChildId ) = [  ];
obj.ChildrenMap( parentId ) = children;

if isempty( children )
dm.rowChanged( parentId, 0, {  } );
if ~strcmp( parentId, obj.Root )
obj.handleDelete( parentId );
end 
else 
dm.rowChanged( parentId, length( children ), {  } );
obj.updateRowChildrenIds( parentId );
for child = children
if obj.ChildrenMap.isKey( child )
dm.rowChanged( child, length( obj.ChildrenMap( child ) ), {  } );
obj.updateRowChildrenIds( child );
end 
end 
end 
end 

function issueTotals( obj )
notifObjs = obj.getCurrentNotifObjs;
if isempty( notifObjs )
result = struct( 'type', '' );
else 
c = categorical( [ notifObjs.Severity ] );
[ cnts, sev ] = histcounts( c );

temp = str2double( sev );
severity = arrayfun( @( sev ){ char( classdiagram.app.core.notifications.Severity( sev ) ) }, temp );
cntsCell = num2cell( cnts );
res = [ severity;cntsCell ];
result = cell2struct( res, severity, 2 );
result = result( end  );
end 
result.type = obj.TotalsType;
message.publish( obj.channel, result );
end 

function deleteAll( obj )
dm = obj.getDataModel;

dm.rowChanged( "", 0, {  } );
obj.ChildrenMap = containers.Map;
obj.ChildrenMap( obj.Root ) = [  ];
obj.uuid2ObjMap = containers.Map;
obj.issueTotals;
end 

function deleteByUuid( obj, notifUuids )
if ~isa( notifUuids, 'cell' )
notifUuids = num2cell( notifUuids );
end 
remove( obj.uuid2ObjMap, notifUuids );
dm = obj.getDataModel;

remove( obj.ChildrenMap, notifUuids );
for ii = 1:numel( notifUuids )
uuid = notifUuids{ ii };
dm.rowChanged( uuid, 0, {  } );
obj.handleDelete( uuid );
end 
obj.issueTotals;
end 

function notifObjs = getCurrentNotifObjs( obj )
uuids = keys( obj.ChildrenMap );
allObjs = classdiagram.app.core.notifications.mapUtils.getValsByMultipleKeys(  ...
obj.uuid2ObjMap, uuids );
idx = cellfun( @( obj )classdiagram.app.core.notifications.output.WDFNotificationsProvider.isNotifObj(  ...
obj ), allObjs );
allObjs( ~idx ) = [  ];
notifObjs = [ allObjs{ : } ];
if isa( notifObjs, 'cell' )
notifObjs = [ notifObjs{ : } ];
end 
end 
end 

methods ( Static )
function bool = isNotifObj( input )
if isa( input, 'cell' )
input = [ input{ : } ];
end 
bool = isa( input, 'classdiagram.app.core.notifications.notifications.AbstractNotification' );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpAXZUv2.p.
% Please follow local copyright laws when handling this file.

