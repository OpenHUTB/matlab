classdef ( Sealed )WorkspaceTypeEditor < handle



properties ( Constant, GetAccess = private )
PAGE_PATH = 'toolbox/coder/coderapp/types/web/codertypedialog'
EDITOR_PROPERTY = 'workspaceTypeEditor.owner'
CH_STATE_PUSH = 'stateChanged'
CH_STATE_GET = { 'getState/request', 'getState/reply' }
CH_PROMOTE_VARIABLE = { 'promote/request', 'promote/reply' }
CH_NEW_TYPE = { 'newType/request', 'newType/reply' }
CH_CHILD_FROM = { 'newChildFrom/request', 'newChildFrom/reply' }
CH_REMOVE_TYPE = { 'deleteType/request', 'deleteType/reply' }
CH_DEFINE_BY_EXAMPLE = { 'byExample/request', 'byExample/reply' }
CH_EDIT_TYPE_NODES = { 'editType/request', 'editType/reply' }
CH_CLEAR = { 'clear/request', 'clear/reply' }
CH_SYNC = { 'sync/request', 'sync/reply' }
CH_LOAD = { 'load/request', 'load/reply' }
CH_EXPORT = { 'export/request', 'export/reply' }
CH_UNDO = { 'undo/request', 'undo/reply' }, 
CH_HELP = { 'help/request', 'help/reply' }
STATE_KEYS = { 'busy', 'workspace', 'code', 'undoRedoState',  ...
'typeChannelGroup', 'creationSupported', 'dirtyStateChanged' }
end 

properties ( SetAccess = immutable )
Id uint32
Model codergui.internal.typedialog.WorkspaceTypeEditorModel
TypeApplet codergui.internal.type.TypeApplet
end 

properties ( Hidden, Dependent, SetAccess = immutable )
Client
TypeMaker
end 

properties ( SetAccess = immutable, GetAccess = private )
MessagingHelper
TypeView
end 

properties ( Access = private )
Started = false
Handles = {  }
Tracking = false;
PendingStateKeys = {  }
end 

methods 
function this = WorkspaceTypeEditor( varargin )
persistent ip;
persistent idCounter;

if isempty( ip )
ip = inputParser(  );
ip.addParameter( 'Model', [  ], @( v )isempty( v ) || isa( v, 'codergui.internal.typedialog.WorkspaceTypeEditorModel' ) );
ip.addParameter( 'TypeMaker', [  ], @( v )isempty( v ) || isa( v, 'codergui.internal.type.TypeMaker' ) );
ip.addParameter( 'Page', this.PAGE_PATH, @ischar );
ip.addParameter( 'Applet', [  ], @( v )isempty( v ) || isa( v, 'codergui.internal.type.TypeApplet' ) );
ip.addParameter( 'UseMinifiedRtc', [  ], @islogical );
idCounter = uint32( 0 );
end 
ip.parse( varargin{ : } );
if ~isempty( ip.Results.Model ) && ~isempty( ip.Results.TypeMaker )
error( 'Only one of Model and TypeMaker parameters may be used at a time' );
end 

if ~isempty( ip.Results.UseMinifiedRtc )
typeViewArgs = { 'UseMinifiedRtc', ip.Results.UseMinifiedRtc };
else 
typeViewArgs = {  };
end 


if codergui.internal.isMatlabOnline(  )
closeArgs = { 'CloseHandler', @(  )this.handleOnlineWindowClose(  ) };
else 
closeArgs = {  };
end 
this.TypeView = codergui.internal.type.WebTypeView( [  ], 'Page', ip.Results.Page, 'ReadOnly', true, typeViewArgs{ : }, closeArgs{ : } );
this.TypeView.WebClient.setProperty( this.EDITOR_PROPERTY, this );
this.TypeView.WebClient.WindowTitle = message( 'coderApp:uicommon:wteWindowTitle' ).getString(  );

if isempty( ip.Results.Applet )
this.TypeApplet = codergui.internal.type.TypeApplet( 'Views', this.TypeView );
else 
this.TypeApplet = ip.Results.Applet;
this.TypeApplet.addView( this.TypeView );
end 
if isempty( ip.Results.Model )
modelArgs = { 'AutoStart', false };
if ~isempty( ip.Results.TypeMaker )
modelArgs( end  + 1:end  + 2 ) = { 'TypeMaker', ip.Results.TypeMaker };
end 
this.Model = codergui.internal.typedialog.WorkspaceTypeEditorModel( modelArgs{ : } );
else 
this.Model = ip.Results.Model;
end 
this.TypeApplet.Model = this.Model.TypeMaker;

this.MessagingHelper = codergui.internal.MessagingHelper(  ...
'WebClient', this.TypeView.WebClient, 'BindTo', this, 'ChannelPrefix', sprintf( 'typedialog/%d', this.Id ),  ...
'ErrorFormatter', @( ~, rawErr, requestId )this.formatError( rawErr, requestId ) );

idCounter = idCounter + 1;
this.Id = idCounter;
end 

function start( this )
if this.Started
return 
end 
this.Started = true;

addlistener( this.Client, 'Disposed', 'PostSet', @( ~, ~ )this.delete(  ) );
this.MessagingHelper.multiMap( {  ...
'output', this.CH_STATE_GET{ : }, 'handleGetState'; ...
'output', this.CH_PROMOTE_VARIABLE{ : }, 'handlePromoteVariable'; ...
'output', this.CH_NEW_TYPE{ : }, 'handleNewType'; ...
'output', this.CH_REMOVE_TYPE{ : }, 'handleDeleteType'; ...
'output', this.CH_DEFINE_BY_EXAMPLE{ : }, 'handleDefineByExample'; ...
'output', this.CH_EDIT_TYPE_NODES{ : }, 'handleEditTypeNodes'; ...
'output', this.CH_CLEAR{ : }, 'handleClear'; ...
'output', this.CH_SYNC{ : }, 'handleSync'; ...
'output', this.CH_LOAD{ : }, 'handleLoad'; ...
'output', this.CH_EXPORT{ : }, 'handleExport'; ...
'output', this.CH_UNDO{ : }, 'handleUndo'; ...
'output', this.CH_CHILD_FROM{ : }, 'handleChildFrom'; ...
'output', this.CH_HELP{ : }, 'handleHelp' ...
 } );
this.MessagingHelper.attach(  );
this.TypeApplet.start(  );
this.attachToModel(  );
this.Model.start(  );
this.pushModelState(  );
end 

function show( this )
this.start(  );
this.TypeView.show(  );
end 

function client = get.Client( this )
client = this.TypeView.WebClient;
end 

function typeMaker = get.TypeMaker( this )
typeMaker = this.Model.TypeMaker;
end 

function delete( this )
this.Handles = {  };

this.TypeView.delete(  );
this.MessagingHelper.delete(  );
this.Model.delete(  );
end 
end 

methods ( Hidden )
function selectTypeRoot( this, typeRoot )
R36
this
typeRoot( 1, 1 )codergui.internal.type.TypeMakerNode
end 
this.TypeView.editType( typeRoot );
end 
end 

methods ( Access = private )
function attachToModel( this )
handles = {  ...
listener( this.Model, 'WorkspaceEntities', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'workspace' ) );
listener( this.Model, 'Locked', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'busy' ) );
listener( this.Model, 'TypeCode', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'code' ) ); ...
listener( this.Model, 'CanCreateEntities', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'creationSupported' ) ); ...
listener( this.Model, 'DirtyNodeIds', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'dirtyStateChanged' ) ); ...
listener( this.Model, 'CanUndo', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'undoRedoState' ) ); ...
listener( this.Model, 'CanRedo', 'PostSet',  ...
@( ~, ~ )this.pushModelState( 'undoRedoState' ) ) ...
 };
this.Handles = [ this.Handles;handles ];
end 

function promise = modelExec( this, methodName, varargin )
promise = feval( methodName, this.Model, varargin{ : } );
promise = promise.then( @untrackPass, @untrackFail );

function result = untrackPass( result )
this.Tracking = false;
this.pushModelState( {  } );
end 

function untrackFail( err )
this.Tracking = false;
this.pushModelState( {  } );
if isa( err, 'MException' )
err.rethrow(  );
else 
error( err );
end 
end 
end 

function onModelLockChanged( this )



this.pushModelState( 'busy' );
end 

function pushModelState( this, keys )
if nargin < 2
keys = this.STATE_KEYS;
elseif ~iscell( keys )
keys = cellstr( keys );
end 
keys = [ keys, this.PendingStateKeys ];
if this.Tracking
this.PendingStateKeys = keys;
return 
else 
this.PendingStateKeys = {  };
keys = unique( keys, 'stable' );
end 
this.MessagingHelper.prefixPublish( this.CH_STATE_PUSH, this.getSerializableState( keys ) );
end 

function state = getSerializableState( this, keys )
if nargin < 2
keys = this.STATE_KEYS;
end 
state = struct(  );
for i = 1:numel( keys )
switch keys{ i }
case 'busy'
state.busy = this.Model.Locked;
case 'workspace'
state.workspace = num2cell( codergui.evalprivate( 'filterObjectForJson',  ...
this.Model.WorkspaceEntities ) );
case 'code'
state.code.byNode = num2cell( this.Model.TypeCode );
state.code.changes = num2cell( this.Model.TypeCodeChanges );
case 'typeChannelGroup'
state.typeChannelGroup = this.TypeView.ChannelRoot;
case 'creationSupported'
state.creationSupported = this.Model.CanCreateEntities;
case 'dirtyStateChanged'
state.dirtyNodeIds = num2cell( this.Model.DirtyNodeIds );
case 'undoRedoState'
state.undoRedoState.undo = this.Model.CanUndo;
state.undoRedoState.redo = this.Model.CanRedo;
otherwise 
assert( false, 'Unrecognized state key "%s"', keys{ i } );
end 
end 
end 

function handleOnlineWindowClose( this )
result = questdlg(  ...
message( 'coderApp:typeDialogGui:closeConfirmationTitle' ).getString(  ),  ...
message( 'coderApp:typeDialogGui:closeConfirmationMessage' ).getString(  ),  ...
message( 'coderApp:typeDialogGui:closeConfirmationYes' ).getString(  ),  ...
message( 'coderApp:typeDialogGui:closeConfirmationNo' ).getString(  ),  ...
message( 'coderApp:typeDialogGui:closeConfirmationYes' ).getString(  ) );
switch lower( result )
case 'yes'
promise = this.handleSync( struct( 'nodeIds', this.Model.DirtyNodeIds ) );
promise.finally( @(  )this.delete(  ) );
case 'no'
this.delete(  );
end 
end 

function payload = formatError( ~, rawErr, requestId )
if ~isempty( requestId )
payload.requestId = requestId;
end 
payload.success = false;
if ~ischar( rawErr ) && ~isstring( rawErr )
if ~isempty( rawErr.cause )
errMessage = append( rawErr.message, ' ', rawErr.cause{ 1 }.message );
else 
errMessage = rawErr.message;
end 
payload.error = struct( 'identifier', rawErr.identifier, 'message', errMessage,  ...
'internal', codergui.internal.util.isInternalError( rawErr ) );
else 
payload.error = rawErr;
end 
end 
end 

methods ( Access = ?codergui.internal.MessagingHelper )
function promise = handleGetState( this, msg )
promise = this.Model.runWithLock( @doGetState );

function response = doGetState
if isfield( msg, 'keys' )
keyArgs = { msg.keys };
else 
keyArgs = {  };
end 
response = this.getSerializableState( keyArgs{ : } );
end 
end 

function promise = handlePromoteVariable( this, msg )
if isfield( msg, 'typeVarName' )
typeVarName = msg.typeVarName;
else 
typeVarName = '';
end 

promise = this.modelExec( 'promoteFromWorkspace', msg.varName, typeVarName,  ...
isfield( msg, 'constant' ) && msg.constant ).then( @afterPromoteVariable );

function response = afterPromoteVariable( node )
response.typeVarName = node.Address;
response.nodeId = node.Id;
end 
end 

function promise = handleNewType( this, msg )
extraArgs = {  };
methodName = 'newType';
if isfield( msg, 'type' ) && ~isempty( msg.type )
extraArgs = { msg.type };
methodName = 'cloneType';
elseif isfield( msg, 'exampleVar' )
extraArgs = { msg.exampleVar, 'variable' };
elseif isfield( msg, 'exampleCode' )
extraArgs = { msg.exampleCode, 'expression' };
end 
if ~isfield( msg, 'variableName' ) || isempty( msg.variableName )
variableName = '';
else 
variableName = msg.variableName;
end 
promise = this.modelExec( methodName, variableName, extraArgs{ : } );
promise = promise.then( @afterNewType );

function response = afterNewType( typeRoot )
response.nodeId = typeRoot.Id;
end 
end 

function promise = handleDefineByExample( this, msg )
promise = this.modelExec( 'defineNodeByExample',  ...
msg.node, msg.code ).then( @afterDefineByExample );

function response = afterDefineByExample( ~ )
response.node = msg.node;
response.success = true;
end 
end 

function promise = handleDeleteType( this, msg )
if isfield( msg, 'all' )
deleteArg = {  };
elseif isfield( msg, 'nodeId' )
deleteArg = { msg.nodeId };
else 
deleteArg = { msg.typeName };
end 
promise = this.modelExec( 'deleteTypes', deleteArg{ : } ).then( @afterDeleteTypes );

function response = afterDeleteTypes( ~ )
response.success = true;
end 
end 

function promise = handleEditTypeNodes( this, msg )
edits = msg.edits;
if ~iscell( edits )
edits = num2cell( edits );
end 





byExampleSelect = cellfun( @( e )e.editType == "byExample", edits );
if nnz( byExampleSelect ) > 1
codergui.internal.util.throwInternal(  ...
'WorkspaceTypeEditor only supports one define-by-example at a time' );
end 

results = cell( 1, numel( edits ) );
promises{ 1 } = this.modelExec( 'modifyTypes', @applyModifications );

exampleEdit = edits( byExampleSelect );
if ~isempty( exampleEdit )
promises{ 2 } = this.modelExec( 'defineNodeByExample', exampleEdit.node, exampleEdit.code );
promises{ 2 } = promises{ 2 }.then( @finishByExample );
end 


promise = codergui.internal.util.Promise.all( promises{ : } ).then( @afterTypeModifications );

function response = applyModifications( ~ )
results( ~byExampleSelect ) = this.TypeView.applyTypeEdits( edits( ~byExampleSelect ) );
response = results;
end 

function response = finishByExample( ~ )
results( byExampleSelect ) = struct(  );
response = results;
end 

function response = afterTypeModifications( ~ )
response = results;
end 
end 

function promise = handleSync( this, msg )
args = {  };
if isfield( msg, 'nodeIds' )
args{ 1 } = msg.nodeIds;
end 
promise = this.modelExec( 'flushTypes', args{ : } );
promise = promise.then( @afterSync, @onSyncFail );

function response = afterSync( ~ )
response.success = true;
end 

function response = onSyncFail( result )
response.success = false;
response.result = result;
end 
end 

function promise = handleLoad( this, msg )
args = {  };
if isfield( msg, 'nodeIds' )
args{ 1 } = msg.nodeIds;
end 
promise = this.modelExec( 'loadTypes', args{ : } );
promise = promise.then( @afterLoad );

function response = afterLoad( ~ )
response.success = true;
end 
end 

function promise = handleClear( this, msg )
promise = this.Model.runWithLock( @doClear );

function response = doClear(  )
cellfun( @clearvars, msg.variableNames );
response.success = true;
end 
end 

function promise = handleExport( this, msg )
switch validatestring( msg.target, { 'mat', 'script' } )
case 'mat'
exportMethod = 'exportMatFile';
case 'script'
exportMethod = 'exportScript';
end 
args = { msg.file };
if isfield( msg, 'nodes' )
args{ end  + 1 } = msg.nodes;
end 
promise = this.modelExec( exportMethod, args{ : } );
promise = promise.then( @afterExport );

function response = afterExport( ~ )
response.success = true;
end 
end 

function promise = handleUndo( this, msg )
if ~isfield( msg, 'isUndo' ) || ~msg.isUndo
undoMethod = 'redo';
else 
undoMethod = 'undo';
end 
if isfield( msg, 'count' )
count = msg.count;
else 
count = 1;
end 
promise = this.modelExec( undoMethod, count );
promise = promise.then( @afterUndoRedo );

function response = afterUndoRedo( ~ )
response.success = true;
end 
end 

function promise = handleChildFrom( this, msg )
if isfield( msg, 'code' )
fromArg = msg.code;
elseif isfield( msg, 'template' ) && ~isempty( msg.template )
fromArg = msg.template;
else 
fromArg = '';
end 
if isfield( msg, 'address' )
extrArgs = { msg.address };
else 
extrArgs = {  };
end 
promise = this.modelExec( 'newChildFrom', msg.parentId,  ...
fromArg, extrArgs{ : } ).then( @afterChildFrom );

function response = afterChildFrom( ~ )
response.success = true;
end 
end 

function promise = handleHelp( this, msg )
if isfield( msg, 'node' )
promise = this.modelExec( 'openTypeReferencePage', msg.node );
else 
if isfield( msg, 'anchorId' )
anchorId = msg.anchorId;
else 
anchorId = '';
end 
promise = this.modelExec( 'openDocPage', anchorId );
end 
end 
end 

methods ( Static )
function instance = getOrCreate(  )
instance = codergui.internal.typedialog.WorkspaceTypeEditor.getActiveInstances(  );
if ~isempty( instance )
instance = instance( 1 );
else 
instance = codergui.internal.typedialog.WorkspaceTypeEditor(  );
end 
end 

function activeInstances = getActiveInstances(  )
webClients = codergui.WebClient.getWebClients(  ...
@( c )isvalid( c ) && c.hasProperty( codergui.internal.typedialog.WorkspaceTypeEditor.EDITOR_PROPERTY ) );
activeInstances = cellfun( @( c )c.getProperty( codergui.internal.typedialog.WorkspaceTypeEditor.EDITOR_PROPERTY ), webClients );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpL7pPk4.p.
% Please follow local copyright laws when handling this file.

