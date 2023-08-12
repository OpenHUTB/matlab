classdef CartesianController < handle

properties ( Access = private )
RequestResponseSubscription
ResponseToken
ResponseData
WaitingForResponse
HTML
ID = 0
ErrorData
end 

properties ( SetAccess = private )
RequestResponseChannel
end 

properties ( Access = private, Constant )
Timeout = 10
RELEASE_URL = "toolbox/shared/threejs/viewer/index.html?clientid="
DEBUG_URL = "toolbox/shared/threejs/viewer/index-debug.html?clientid="
end 

methods 
function controller = CartesianController( Figure, NameValueArgs )
R36
Figure
NameValueArgs.UseDebug = false
end 
controller.HTML = uihtml( Figure );
controller.HTML.Position = [ 0, 0, Figure.Position( 3 ), Figure.Position( 4 ) ];
controller.setUpChannel( NameValueArgs.UseDebug );


setappdata( groot, 'CartesianViewerWebGraphicsSupport', false );
webGraphicsInfo = controller.requestResponse( 'queryWebGraphics' );
if webGraphicsInfo.IsWebGraphicsSupported
setappdata( groot, 'CartesianViewerWebGraphicsSupport', true );
else 
error( message( 'shared_threejs:viewer:ThreejsUnsupportedWebGraphics' ) );
end 


controller.request( 'show', struct(  ) );
end 

function request( controller, request, data )
controller.ResponseToken = getResponseToken;
controller.WaitingForResponse = true;
message.publish( controller.RequestResponseChannel, struct(  ...
'Token', controller.ResponseToken,  ...
'Type', request,  ...
'Args', data ) );
controller.waitForResponse;
end 

function outputData = requestResponse( controller, request )
controller.request( request, struct );
outputData = controller.ResponseData;
end 

function delete( controller )
if ~isempty( controller.RequestResponseSubscription )
message.unsubscribe( controller.RequestResponseSubscription );
end 
end 

function ID = getID( controller, numIDs )
if nargin < 2
numIDs = 1;
end 
ID = cell( numIDs, 1 );
for k = 1:numIDs
ID{ k } = controller.ID;
controller.ID = controller.ID + 1;
end 
end 

end 

methods ( Access = private )
function setUpChannel( controller, useDebug )

[ ~, channelName ] = fileparts( tempname );
controller.RequestResponseChannel = [ '/threejsviewer-ui/', channelName ];
controller.ResponseToken = "Initialization";
controller.RequestResponseSubscription = message.subscribe( controller.RequestResponseChannel,  ...
@( msg )controller.onRequestResponse( msg ) );
controller.WaitingForResponse = true;


if useDebug
fullURL = controller.DEBUG_URL + channelName;
else 
fullURL = controller.RELEASE_URL + channelName;
end 
fullURL = connector.getUrl( fullURL );
controller.HTML.HTMLSource = fullURL;


controller.waitForResponse;
end 

function onRequestResponse( controller, msg )
if ( isfield( msg, 'Token' ) && strcmp( msg.Token, controller.ResponseToken ) )
controller.WaitingForResponse = false;
controller.ResponseData = msg.Message;
elseif ( isfield( msg, 'IsError' ) && msg.IsError )
controller.ErrorData = msg;
end 
end 

function waitForResponse( controller )
timeElapsed = 0;
while ( controller.WaitingForResponse && timeElapsed < controller.Timeout )
pause( 0.01 );
timeElapsed = timeElapsed + 0.01;
end 
if ( timeElapsed > controller.Timeout )
disp( controller.ErrorData )
error( "Timed out" );
end 
end 
end 
end 

function token = getResponseToken
[ ~, token ] = fileparts( tempname );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWDLkb3.p.
% Please follow local copyright laws when handling this file.

