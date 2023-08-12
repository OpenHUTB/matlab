classdef Batchlist < handle
properties ( Access = private )
ByUuid;

ByTarget;

ByAction;
end 

methods 
function obj = Batchlist(  )
obj.ByUuid = containers.Map;
obj.ByTarget = containers.Map;
obj.ByAction = containers.Map;
end 

function add( obj, notifications )
import classdiagram.app.core.notifications.mapUtils;

for notifObj = notifications
uuid = notifObj.Uuid;
obj.ByUuid( uuid ) = notifObj;
targets = classdiagram.app.core.notifications.struct2vector( notifObj.Target );
mapUtils.addEntries( obj.ByTarget, targets, uuid );
mapUtils.addEntry( obj.ByAction, notifObj.ActionInfoUuid, uuid );
end 
end 


function [ notifKeys, targetVals ] = getPersistentKVSet( obj, notifications )
persistidx = ~[ notifications.Transient ];
persist = notifications( persistidx );
[ notifKeys, targetVals ] = obj.notif2targetKVSet( persist );
end 

function notifObjs = getNotificationsByAction( obj, action, optional )
R36
obj( 1, 1 );
action( 1, 1 )string;
optional.not( 1, 1 )logical = false;
end 

import classdiagram.app.core.notifications.mapUtils;

notifObjs = classdiagram.app.core.notifications.notifications.AbstractNotification.empty( 1, 0 );

if ~obj.ByAction.isKey( action )
return ;
end 
if optional.not

notifUuids = mapUtils.getValsByMultipleKeys( obj.ByAction, action, not = true );
else 
notifUuids = obj.ByAction( action );
end 
nObjs = mapUtils.getValsByMultipleKeys( obj.ByUuid, notifUuids );
if isempty( nObjs )

return ;
end 
notifObjs = [ nObjs{ : } ];
end 

function notifObjs = getAllNotifications( obj )
notifObjs = values( obj.ByUuid );
notifObjs = [ notifObjs{ : } ];

if isempty( notifObjs )
notifObjs = classdiagram.app.core.notifications.notifications.AbstractNotification.empty( 1, 0 );
end 
end 

function [ keySet, valueSet ] = notif2targetKVSet( ~, notifications )

if isempty( notifications )
keySet = [  ];
valueSet = [  ];
return ;
end 
if isa( notifications, 'cell' )
keySet = [ notifications{ : } ];
else 
keySet = notifications;
end 
targetStructs = { keySet.Target };
valueSet = cellfun( @( s )classdiagram.app.core.notifications.struct2vector( s ), targetStructs );
if isa( valueSet, 'cell' )
valueSet = [ valueSet{ : } ];
end 
end 

function clearAll( obj )
obj.ByUuid = containers.Map;
obj.ByTarget = containers.Map;
obj.ByAction = containers.Map;
end 


function clearIssued( obj )
notifObjs = obj.getAllNotifications;
if isempty( notifObjs )
return ;
end 
idx = [ notifObjs.Issued ];
issuedObjs = notifObjs( idx );
if ~isempty( issuedObjs )
obj.removeByUuid( [ issuedObjs.Uuid ] );
end 
end 

function remove( obj, mapType, key )
R36
obj( 1, 1 )classdiagram.app.core.notifications.Batchlist;
mapType( 1, 1 )string{ mustBeMember( mapType, { 'Uuid', 'Target', 'Action' } ) };
key( 1, : )string;
end 
obj.( [ 'removeBy', char( mapType ) ] )( key );
end 

function removeFromTargets( obj, notifUuids, notifTargets )
map = obj.ByTarget;
for targets = notifTargets'
classdiagram.app.core.notifications.mapUtils.removeEntry( map, targets', notifUuids )
end 
end 

function removeByUuid( obj, mapKeys )
import classdiagram.app.core.notifications.mapUtils;

map = obj.ByUuid;
notifs = mapUtils.removeKey( map, mapKeys );
if isempty( notifs )
return ;
end 
notifUuids = [ notifs.Uuid ];
targets = arrayfun( @( n )classdiagram.app.core.notifications.struct2vector( n.Target ), notifs );
obj.removeFromTargets( notifUuids, targets );
map = obj.ByAction;
mapUtils.removeEntry( map, [ notifs.ActionInfoUuid ], notifUuids );
end 

function removeByTarget( obj, mapKeys )
import classdiagram.app.core.notifications.mapUtils;

map = obj.ByTarget;
notifUuids = mapUtils.removeKey( map, mapKeys );
if isempty( notifUuids )
return ;
end 
map = obj.ByUuid;
notifs = mapUtils.removeKey( map, notifUuids );
notifActions = [ notifs.ActionInfoUuid ];
map = obj.ByAction;
mapUtils.removeEntry( map, notifActions, notifUuids );
end 

function removeByAction( obj, keys )
import classdiagram.app.core.notifications.mapUtils;

map = obj.ByAction;
notifUuids = mapUtils.removeKey( map, keys );
map = obj.ByUuid;
notifs = mapUtils.removeKey( map, notifUuids );
obj.removeFromTargets( notifUuids, [ notifs.Target ] );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpGAddVd.p.
% Please follow local copyright laws when handling this file.

