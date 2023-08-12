classdef WDFNotifier < handle & diagram.syntax.SyntaxListener

properties ( Access = private )
App;
Batchlist;
notificationMode;


channel;
listener;


readyToSendListener event.listener;


actionInfo;
batchOperations = [  ];


tempActionInfo;
tempBatchMode;
actionStack = [  ];


editor;
editorUuid;
wdfChannel;


docsChannel;
docsListener;

wdfNotificationsOn;



wdfNotificationsProvider;
wdfNotificationsDataModel mdom.DataModel;

dwRegistry;

handleWidgetDeletedListener event.listener;


i18nActionCatalog;
end 

properties ( Access = private, SetObservable )
isReadyToSend = false;
end 

properties 
url;
end 

methods 
function cai = get.tempActionInfo( obj )

cai = [  ];
if ~isempty( obj.actionStack )
cai = obj.actionStack( 1 );
else 
cai = obj.tempActionInfo;
end 
end 
end 

methods 
function obj = WDFNotifier( app, editor )
s = settings;
obj.App = app;
obj.editor = editor;
obj.editorUuid = editor.uuid;
obj.Batchlist = classdiagram.app.core.notifications.Batchlist;
obj.notificationMode = classdiagram.app.core.notifications.Mode.CL;
obj.dwRegistry = classdiagram.app.core.notifications.DWRegistry;
obj.handleWidgetDeletedListener = addlistener(  ...
obj.dwRegistry, 'DeletedWidget',  ...
@( src, evt )obj.handleWidgetDeleted( src, evt ) );
obj.attachNotificationsErrorHandler(  );

obj.channel = strcat( '/Classdiagram/', editor.uuid, '/notifications' );
obj.listener = message.subscribe( obj.channel,  ...
@( msg )obj.processClientMsg( msg ) );
obj.readyToSendListener = addlistener(  ...
obj, 'isReadyToSend', 'PostSet',  ...
@( src, evt )ready( obj, src, evt ) );
obj.docsChannel = strcat( '/Classdiagram/', editor.uuid, '/matlabDocs' );
obj.docsListener = message.subscribe( obj.docsChannel,  ...
@( msg )obj.processDocsRequest( msg ) );

obj.wdfChannel = strcat( '/WDF/', editor.uuid, '/notifications' );
obj.wdfNotificationsProvider = classdiagram.app.core.notifications.output.WDFNotificationsProvider(  ...
strcat( '/Classdiagram/', editor.uuid, '/notifications' ) );

function dm = initializeDataModel( provider, queryString )
dm = mdom.DataModel( provider );
obj.url = [ editor.url, [ '&', queryString, '=' ], dm.getID ];

dm.columnChanged( 1, {  } );
dm.rowChanged( '', provider.RootCount, {  } );
end 

obj.wdfNotificationsDataModel = initializeDataModel( obj.wdfNotificationsProvider, 'wdfNotificationsModelID' );
obj.setBatchMode( false );
editor.getSyntax(  ).attachListener( obj );
end 

function registerCleanUpRules( obj, rules )
obj.dwRegistry.setCleanUpRules( rules );
obj.wdfNotificationsProvider.setCleanUpRules( rules );
end 

function registerI18nActionCatalog( obj, actionCatalog )
obj.i18nActionCatalog = string( actionCatalog );
if ~endsWith( obj.i18nActionCatalog, ':' )
obj.i18nActionCatalog = obj.i18nActionCatalog + ":";
end 
end 

function delete( obj )
message.unsubscribe( obj.listener );
message.unsubscribe( obj.docsListener );
end 

function batchNotifications( obj, callback, optional )
R36
obj( 1, 1 )classdiagram.app.core.notifications.WDFNotifier;
callback( 1, 1 )function_handle;
optional.Action( 1, 1 )string = string.empty;
end 
obj.setActionInfo( optional.Action );
obj.setBatchMode( true );

obj.batchOperations = [  ];
try 
callback( obj.batchOperations );
if numel( obj.actionStack ) == 1
obj.exitBatchMode;
else 
obj.actionStack( end  ) = [  ];
end 
catch ex
notifObj = classdiagram.app.core.notifications.notifications.WDFNotification(  ...
ex, Transient = 0, Severity =  ...
classdiagram.app.core.notifications.Severity.Error );
obj.processNotification( notifObj );
obj.exitBatchMode;
end 
end 

function onSyntaxChange( obj, report )

function uuids = getRemoved( rem )

uuids = [  ];
sections = [ "diagrams", "entities", "ports", "connections" ];
idx = arrayfun( @( sec )~isempty( rem.( sec ) ), sections );
rsec = sections( idx );

if isempty( rsec )
return ;
end 
uuids = arrayfun( @( sec )string( { rem.( sec ).uuid } ), rsec, 'uni', false );
uuids = [ uuids{ : } ];
end 

removedRep = report.removed;
uuids = getRemoved( removedRep );
if isempty( uuids )
return ;
end 



[ elements, widgets ] = obj.dwRegistry.getAllTargets(  );
idx = ismember( elements, uuids );
arrayfun( @( w )obj.dwRegistry.deleteWidget( w ), widgets( idx ) );
end 



function flush( obj, optional )
R36
obj( 1, 1 );

optional.fromReady( 1, 1 )logical = false;
end 
cai = obj.getCurrentActionInfo(  );
if optional.fromReady
if ~obj.getBatchMode

notifObjs = obj.Batchlist.getAllNotifications(  );
else 

notifObjs = obj.Batchlist.getNotificationsByAction(  ...
cai.actionUuid, not = true );
end 
else 

notifObjs = obj.Batchlist.getNotificationsByAction(  ...
cai.actionUuid );
end 
obj.issueNotifications( notifications = notifObjs );
end 

function processNotification( obj, notifObjs, optional )
R36
obj( 1, 1 )classdiagram.app.core.notifications.WDFNotifier;
notifObjs( 1, : )classdiagram.app.core.notifications.notifications.AbstractNotification;
optional.lozengeType( 1, 1 )classdiagram.app.core.notifications.LozengeType =  ...
classdiagram.app.core.notifications.LozengeType.StandardMessage;
end 

obj.addEditorInfo( notifObjs );
if optional.lozengeType == classdiagram.app.core.notifications.LozengeType.UndoRedo
cmdRequest = obj.editor.commandProcessor.getCurrentRequest;
if ~isempty( cmdRequest )
arrayfun( @( o )o.setUndoRedo( cmdRequest ), notifObjs );
end 
end 
if obj.getBatchMode || ~obj.isReadyToSend
obj.Batchlist.add( notifObjs );
elseif ~numel( notifObjs )
obj.issueSuccess;
return ;
else 
obj.issueNotifications( notifications = notifObjs );
end 
end 

function setMode( obj, varargin )
obj.notificationMode =  ...
classdiagram.app.core.utils.Bitops.setFlag(  ...
obj.notificationMode, varargin{ : } );
end 

function unsetMode( obj, varargin )
obj.notificationMode =  ...
classdiagram.app.core.utils.Bitops.unsetFlag(  ...
obj.notificationMode, varargin{ : } );
end 

function resetMode( obj )

if ~obj.isReadyToSend
obj.readyToSendListener = event.listener.empty;
obj.readyToSendListener = addlistener(  ...
obj, 'isReadyToSend', 'PostSet',  ...
@( src, evt )ready( obj, src, evt, '2' ) );
return ;
end 
obj.notificationMode = classdiagram.app.core.notifications.Mode.CL;
end 

function bool = isInUIMode( obj )
bool = classdiagram.app.core.utils.Bitops.isAnySet(  ...
obj.notificationMode,  ...
classdiagram.app.core.notifications.Mode.UI );
end 

function bool = isInCLMode( obj )
bool = classdiagram.app.core.utils.Bitops.isAnySet(  ...
obj.notificationMode,  ...
classdiagram.app.core.notifications.Mode.CL );
end 

function clearNotification( obj, option )
R36
obj( 1, 1 )classdiagram.app.core.notifications.WDFNotifier;
option.keys( 1, : )string;
option.categories( 1, : )string;
option.callback( 1, 1 )function_handle;
option.current( 1, : )classdiagram.app.core.notifications.notifications.AbstractNotification;
end 

function uuids = obj2uuid( uuids )
if isa( uuids,  ...
"classdiagram.app.core.notifications.notifications.AbstractNotification" )
uuids = arrayfun( @( o )o.Uuid, uuids );
end 
end 

if isfield( option, "keys" ) && ~isempty( option.keys )

obj.Batchlist.remove( 'Target', option.keys );
return ;
end 




if isfield( option, "categories" ) && ~isempty( option.categories )


obj.dwRegistry.removeNotification( categories = option.categories );
obj.wdfNotificationsProvider.removeNotification( categories = option.categories );
elseif isfield( option, "callback" )




removeObj = option.callback( obj.dwRegistry.getAllNotifications(  ) );
obj.dwRegistry.removeNotification( uuids = obj2uuid( removeObj ) );
removeObj = option.callback( obj.wdfNotificationsProvider.getNotifObjs(  ) );
obj.wdfNotificationsProvider.removeNotification( uuids = obj2uuid( removeObj ) );
elseif isfield( option, "current" )




obj.dwRegistry.clear( current = option.current );
else 
obj.dwRegistry.clear(  );
end 
end 

function notifObjs = getNotificationsForTarget( obj, target, notifications )
notifObjs = [  ];
targetMap = obj.makeTargetedNotifications( notifications );
if targetMap.isKey( target )
notifObjs = targetMap( target );
end 
end 
end 

methods ( Access = private )
function editorUuid = getCurrentEditorInfo( obj )


editorUuid = obj.editorUuid;
end 

function addEditorInfo( obj, violObjs )
editorUuid = obj.getCurrentEditorInfo(  );
action = obj.getCurrentActionInfo(  );
uiMode = obj.isInUIMode;
clMode = obj.isInCLMode;
arrayfun( @( nObj )nObj.setEditorInfo( action.actionUuid, action.actionName,  ...
editorUuid, uiMode, clMode ), violObjs );
end 

function attachNotificationsErrorHandler( obj )
cp = obj.App.editor.commandProcessor;
notifErrorHandler = classdiagram.app.core.notifications.WDFNotificationsErrorHandler(  ...
obj.App, obj );
cp.setErrorHandler( notifErrorHandler );
end 

function sendToUI( obj, target, notifObjs )







for notifObj = notifObjs
message.publish( obj.channel, struct(  ...
'target', [ target ], 'notifications', notifObj ) );
notifObj.setIssued;
end 

end 

function issueSuccess( obj )
successObj = classdiagram.app.core.notifications.notifications.Success;

obj.wdfNotificationsProvider.setNewRoots( [  ], {  }, {  } );

obj.clearNotification;
obj.sendToUI( string( classdiagram.app.core.notifications.Target.Diagram ),  ...
successObj );
end 

function issueNotifications( obj, option )
R36
obj( 1, 1 )classdiagram.app.core.notifications.WDFNotifier;
option.action( 1, 1 )logical;
option.notifications( 1, : )classdiagram.app.core.notifications.notifications.AbstractNotification;
end 

if isfield( option, "action" ) && option.action
cai = obj.getCurrentActionInfo(  );
notifications = obj.Batchlist.getNotificationsByAction(  ...
cai.actionUuid );
elseif isfield( option, "notifications" )
notifications = option.notifications;
end 
if isempty( notifications )
obj.issueSuccess(  );
return ;
end 

if ~obj.isReadyToSend













[ uiNotifObjs, clNotifObjs ] = getNotificationsByMode( obj, notifications );
idx = ~ismember( clNotifObjs, uiNotifObjs );
obj.issueElementNotifications( clNotifObjs( idx ) );
else 











obj.issueElementNotifications( notifications );
obj.issueDockedNotifications( notifications );
end 
obj.Batchlist.clearIssued;
end 

function [ uiNotifObjs, clNotifObjs ] = getNotificationsByMode( obj, notifications )
idxUI = arrayfun( @( nObj )logical( nObj.UIMode ), notifications );
idxCL = arrayfun( @( nObj )logical( nObj.CommandLineMode ), notifications );
uiNotifObjs = notifications( idxUI );
clNotifObjs = notifications( idxCL );
end 

function issueDockedNotifications( obj, notifications )
cai = obj.getCurrentActionInfo(  );
[ notifKeys, targetVals ] = obj.Batchlist.getPersistentKVSet( notifications );
if isempty( obj.i18nActionCatalog )
cai.actionDisplayName = cai.actionName;
else 
try 
cai.actionDisplayName = message( obj.i18nActionCatalog + string( cai.actionName ) ).getString;
catch 
try 
cai.actionDisplayName = message( cai.actionName ).getString;
catch 
cai.actionDisplayName = cai.actionName;
end 
end 
end 
obj.wdfNotificationsProvider.setNewRoots( cai, notifKeys, targetVals );
end 

function issueToOutputMode( obj, target, uiNotifObjs, clNotifObjs )
if ~isempty( uiNotifObjs ) && ~isempty( target )
obj.sendToUI( target, uiNotifObjs );
end 

if ~isempty( clNotifObjs )
obj.sendToCL( target, clNotifObjs );
end 
end 

function issueDiagramNotifications( obj, notifications )
[ uiNotifObjs, clNotifObjs ] = obj.getNotificationsByMode( notifications );
obj.issueToOutputMode( 'Diagram', uiNotifObjs, clNotifObjs );
end 

function issueElementNotifications( obj, notifications )


obj.clearNotification( current = notifications );

targetMap = obj.makeTargetedNotifications( notifications );
diagramT = string( classdiagram.app.core.notifications.Target.Diagram );
lozengeNotif = classdiagram.app.core.notifications.mapUtils.removeKey( targetMap, diagramT );
obj.issueDiagramNotifications( lozengeNotif );

for k = keys( targetMap )
target = k{ 1 };
targetUuid = target;
notifObjs = targetMap( target );
[ uiNotifObjs, clNotifObjs ] = obj.getNotificationsByMode( notifObjs );


targetUuid = obj.dwRegistry.addNotification( uiNotifObjs, target );

obj.issueToOutputMode( targetUuid, uiNotifObjs, clNotifObjs );
end 
end 

function sendToCL( obj, target, notifObjs )


excludeNotif = arrayfun( @( cl )isa( cl, 'classdiagram.app.core.notifications.notifications.NClassesAddedInfo' ), notifObjs );
msgs = notifObjs( ~excludeNotif );
obj.issueToCommandLine( msgs );
end 

function setActionInfo( obj, action )
if isempty( action )
return ;
end 
tempActionInfo.actionName = action;
tempActionInfo.actionUuid = matlab.lang.internal.uuid;
if isempty( obj.actionStack )
obj.actionStack = tempActionInfo;
else 
obj.actionStack( end  + 1 ) = tempActionInfo;
end 
end 

function msg = makeMessage( ~, varargin )
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
msg = message( [ 'classdiagram_editor:messages:' ...
, varargin{ 1 } ], varargin{ 2:end  } );
end 

function setBatchMode( obj, batchModeOn )
obj.tempBatchMode = batchModeOn;


end 

function batchMode = getBatchMode( obj )
batchMode = obj.tempBatchMode;


end 

function exitBatchMode( obj )
obj.flush(  );


if obj.readyToSendListener.Enabled
obj.tempActionInfo = obj.actionStack( 1 );
end 
obj.actionStack = [  ];
obj.setBatchMode( false );
end 

function cai = getCurrentActionInfo( obj )
if ~isempty( obj.tempActionInfo )
cai = obj.tempActionInfo;
else 
cai.actionName = 'some action name';
cai.actionUuid = matlab.lang.internal.uuid;
obj.tempActionInfo = cai;
end 


end 

function processClientMsg( obj, msg )
function removeUuids = clearAll( notifObjs )
removeUuids = notifObjs;
end 
if strcmpi( msg, 'success' )

obj.isReadyToSend = true;
return ;
end 
if isfield( msg, 'clearAll' )
obj.clearNotification( callback = @( notifObjs )clearAll( notifObjs ) );
end 
end 

function processDocsRequest( obj, msg )
function fcn = convertDocFcn( cb )
fcn = strtrim( regexprep(  ...
regexprep( cb, '^matlab:', '' ),  ...
'%5c', '\' ) );
end 
try 
eval( convertDocFcn( msg ) );
catch ex
obj.processNotification(  ...
classdiagram.app.core.notifications.notifications.WDFNotification(  ...
ex, Transient = false, Severity =  ...
classdiagram.app.core.notifications.Severity.Error ) );
end 
end 


function ready( obj, ~, ~, varargin )
if ~obj.readyToSendListener.Enabled
return ;
end 
obj.flush( fromReady = true );
if ~isempty( varargin )
obj.notificationMode = classdiagram.app.core.notifications.Mode.CL;
end 
obj.readyToSendListener.Enabled = false;
end 

function issueToCommandLine( obj, msgs )
if obj.App.isGlobalDebug
wasTrace = warning( 'on', 'backtrace' );
wasVerbose = warning( 'on', 'verbose' );
else 
wasTrace = warning( 'off', 'backtrace' );
wasVerbose = warning( 'off', 'verbose' );
end 

arrayfun( @( m )warning( m.Category, regexprep( m.DisplayMessage, '\', '\\\' ) ), msgs );

warning( wasTrace );
warning( wasVerbose );

arrayfun( @( m )m.setIssued, msgs );
end 

function handleWidgetDeleted( obj, ~, evtData )
allNotifObjs = obj.wdfNotificationsProvider.getNotifObjs(  );
notifObjs = obj.getNotificationsForTarget( evtData.DwId, allNotifObjs );
if ~isempty( notifObjs )
obj.wdfNotificationsProvider.removeNotification( uuids = [ notifObjs.Uuid ] );
end 
end 

function map = makeTargetedNotifications( ~, notifications )
map = containers.Map;
for notifObj = notifications
targets = classdiagram.app.core.notifications.struct2vector( notifObj.Target );
classdiagram.app.core.notifications.mapUtils.addEntries( map, targets, notifObj );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpt6sgV6.p.
% Please follow local copyright laws when handling this file.

