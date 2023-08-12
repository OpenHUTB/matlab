classdef HistoryView < matlab.ui.componentcontainer.ComponentContainer





properties ( Constant )
DEFAULT_POSITION = [ 20, 20, 300, 400 ]
Channel = '/preprocessingAppHistoryChannel';
HTMLSource = 'toolbox/matlab/datatools/preprocessing/index.html';
end 

properties ( Access = { ?HistoryView, ?matlab.unittest.TestCase }, Transient, NonCopyable, Hidden )
GridLayout matlab.ui.container.GridLayout
UIHTML matlab.ui.control.HTML
end 

properties 
HistoryChangedListener;
HistoryChangedFcn;
GetHistoryListener;
HistoryRequestedFcn;
OpenModeListener;
OpenModeCallbackFcn;
DeleteStepListener;
DeleteStepCallbackFcn;
InsertAboveListener;
InsertBelowListener;
InsertCallbackFcn;
end 

methods 
function obj = HistoryView( NameValueArgs )
R36
NameValueArgs.?matlab.ui.componentcontainer.ComponentContainer
NameValueArgs.Parent
end 

obj@matlab.ui.componentcontainer.ComponentContainer( NameValueArgs );
if isfield( NameValueArgs, "Parent" ) && ~isa( NameValueArgs.Parent, "matlab.ui.container.GridLayout" ) && ~isfield( NameValueArgs, "Position" )
obj.Position = matlab.internal.preprocessingApp.history.HistoryView.DEFAULT_POSITION;
end 
end 
end 

methods ( Access = 'protected' )

function setup( obj )
obj.BackgroundColor = [ 1, 1, 1 ];


obj.GridLayout = uigridlayout( obj, [ 1, 1 ], 'Padding', [ 0, 0, 0, 0 ] );

obj.UIHTML = uihtml( obj.GridLayout, 'Tag', 'DataCleanerHistoryView' );
s = connector.getUrl( obj.HTMLSource );
url = sprintf( '%s&channel=%s', s, obj.Channel );
obj.UIHTML.HTMLSource = url;

obj.GetHistoryListener = message.subscribe( obj.Channel + "/getHistory", @( msg )obj.handleGetHistoryFromClient(  ) );
obj.HistoryChangedListener = message.subscribe( obj.Channel + "/historyChanged", @( msg )obj.handleHistoryChanged( msg ) );
obj.OpenModeListener = message.subscribe( obj.Channel + "/openMode", @( msg )obj.handleOpenModeFromClient( msg ) );
obj.DeleteStepListener = message.subscribe( obj.Channel + "/deleteStep", @( msg )obj.handleDeleteStepFromClient( msg ) );
obj.InsertAboveListener = message.subscribe( obj.Channel + "/insertAbove", @( msg )obj.handleInsertFromClient( 'above', msg ) );
obj.InsertBelowListener = message.subscribe( obj.Channel + "/insertBelow", @( msg )obj.handleInsertFromClient( 'below', msg ) );
end 

function update( ~ )
end 

function handleHistoryChanged( this, msg )



if ~isempty( this.HistoryChangedFcn )
try 
this.HistoryChangedFcn( msg );
catch e
disp( e );
end 
end 
end 


function handleGetHistoryFromClient( this )



if ~isempty( this.HistoryRequestedFcn )
try 
this.HistoryRequestedFcn(  );
catch e
disp( e );
end 
end 
end 

function handleOpenModeFromClient( this, msg )



if ~isempty( this.OpenModeCallbackFcn )
try 
this.OpenModeCallbackFcn( msg );
catch e
disp( e );
end 
end 
end 

function handleDeleteStepFromClient( this, msg )



if ~isempty( this.DeleteStepCallbackFcn )
try 
this.DeleteStepCallbackFcn( msg );
catch e
disp( e );
end 
end 
end 

function handleInsertFromClient( this, type, msg )



if ~isempty( this.InsertCallbackFcn )
try 
this.InsertCallbackFcn( type, msg );
catch e
disp( e );
end 
end 
end 

end 

methods ( Access = 'public' )

function addStep( this, dataStep )

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
R36
this matlab.internal.preprocessingApp.history.HistoryView
dataStep( 1, 1 )struct{ validateInput( dataStep ) }
end 
message.publish( this.Channel + "/addStep", dataStep );
end 

function removeStep( this, dataStep )

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
R36
this matlab.internal.preprocessingApp.history.HistoryView
dataStep( 1, 1 )struct{ validateInput( dataStep ) }
end 
message.publish( this.Channel + "/removeStep", dataStep );
end 

function setHistory( this, historyData )

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
R36
this matlab.internal.preprocessingApp.history.HistoryView
historyData( :, 1 )struct{ validateInput( historyData ) }
end 
message.publish( this.Channel + "/setHistory", historyData );
end 

function setSelection( this, selection )
message.publish( this.Channel + "/setSelection", selection );
end 

function setTasks( this, tasks )
message.publish( this.Channel + "/setPreprocessingTasks", tasks );
end 

function setBusyIndicatorOnClient( this )

message.publish( this.Channel + "/setLoading", {  } );
end 

function removeBusyIndicatorOnClient( this )

message.publish( this.Channel + "/unsetLoading", {  } );
end 

function delete( this )
message.unsubscribe( this.Channel + "/historyChanged" );
message.unsubscribe( this.Channel + "/openMode" );
message.unsubscribe( this.Channel + "/deleteStep" );
message.unsubscribe( this.Channel + "/insertAbove" );
message.unsubscribe( this.Channel + "/insertBelow" );

end 
end 

end 

function validateInput( s )
for i = 1:length( s )
if ~( ( isfield( s( i ), 'id' ) && ( ischar( s( i ).id ) ) || isstring( s( i ).id ) ) &&  ...
( isfield( s( i ), 'label' ) && ( ischar( s( i ).label ) || isstring( s( i ).label ) ) &&  ...
( isfield( s( i ), 'checked' ) && islogical( s( i ).checked ) ) &&  ...
( isfield( s( i ), 'parent' ) && ( ischar( s( i ).parent ) || isstring( s( i ).parent ) || isnan( s( i ).parent ) ) ) &&  ...
( isfield( s( i ), 'index' ) && isnumeric( s( i ).index ) ) ) )
error( 'The structure of the history step is incorrect' )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpm_XRZe.p.
% Please follow local copyright laws when handling this file.

