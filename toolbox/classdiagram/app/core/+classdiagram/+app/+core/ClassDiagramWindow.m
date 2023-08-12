classdef ClassDiagramWindow < handle



properties ( Constant, Access = private )
DefaultWindowPositionAndSize = [ 100, 100, 1024, 648 ];
DefaultDiagramEntityPosition = struct( 'x', 5, 'y', 5 );
end 

properties ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
?classdiagram.app.core.ClassDiagramWindow,  ...
 } )
ww matlab.internal.webwindow;
end 

properties 
url;
end 

properties ( Dependent )

Tag string;
end 

properties ( Access = private )
App;
end 

methods 
function value = get.Tag( obj )
value = obj.ww.Tag;
end 

function set.Tag( obj, value )
R36
obj( 1, 1 )classdiagram.app.core.ClassDiagramWindow;
value string;
end 
if ~isempty( obj.ww )
obj.ww.Tag = value;
end 
end 

function value = get.ww( obj )
value = obj.ww;
end 

function value = get.url( obj )
value = obj.url;
end 

function set.url( obj, value )
R36
obj( 1, 1 )classdiagram.app.core.ClassDiagramWindow;
value;
end 
obj.url = value;
end 
end 

methods 
function obj = ClassDiagramWindow( app, url )
import matlab.internal.lang.capability.Capability;

obj.App = app;
isInMatlabOnline = ~Capability.isSupported( Capability.LocalClient );
obj.url = [ url, '&isInMATLABOnline=', num2str( isInMatlabOnline ) ];
end 

function visible = isVisible( obj )
visible = obj.isWwValid(  ) && obj.ww.isVisible;
end 

function show( obj, isDebug )
if obj.isWwValid(  )
obj.ww.show(  );
obj.raise(  );
return ;
end 



connector.ensureServiceOn(  );
connector.newNonce;
appUrl = connector.getUrl( obj.url );
if ~exist( 'isDebug', 'var' )
isDebug = false;
end 
if ( isDebug )
appUrl = regexprep( appUrl, 'index', 'index-debug' );
web( appUrl, '-browser' );
else 
if obj.isWwValid(  )
obj.ww.URL = appUrl;
show( obj.ww );
else 

obj.ww = matlab.internal.webwindow( appUrl, matlab.internal.getDebugPort );
obj.ww.show(  );
obj.raise(  );
obj.setWindowTitle( obj.getDefaultTitle(  ) );
activeFilePath = obj.App.getFilePath(  );

if isempty( activeFilePath )
obj.ww.Tag = 'newClassDiagramViewer';
else 
obj.ww.Tag = activeFilePath;
end 
obj.setWindowPosition( obj.DefaultWindowPositionAndSize );







obj.ww.CustomWindowClosingCallback = @( ~, ~ )obj.windowCloseRequestCallback( obj );
obj.ww.addlistener( 'ObjectBeingDestroyed', @( ~, ~ )obj.onWindowClosedCallback( obj ) );
end 
wm = classdiagram.app.core.WindowManager.Instance;
wm.registerOpenWindow( obj.App );
end 
end 

function raise( obj )

if obj.isWwValid && obj.ww.isVisible
obj.ww.bringToFront(  );
end 
end 

function close( obj )
if obj.isVisible
obj.App.publishData( struct( 'type', 'askCanClose' ) );
end 
end 
end 

methods ( Access = private )
function title = getDefaultTitle( ~ )
messageObject = message( 'classdiagram_editor:messages:TsMainTabTitle' );
title = messageObject.getString(  );
end 

function setWindowPosition( obj, position )
if obj.isWwValid(  )
obj.ww.Position = position;
end 
end 

function setWindowTitle( obj, title )
if obj.isWwValid(  )
obj.ww.Title = title;
end 
end 

function isValid = isWwValid( obj )
isValid = ~isempty( obj.ww ) && isvalid( obj.ww ) && obj.ww.isWindowValid;
end 
end 

methods ( Static, Access = private )
function onWindowClosedCallback( obj )
wm = classdiagram.app.core.WindowManager.Instance;
wm.unregisterClosingWindow( obj.App );


if obj.isVisible
obj.ww.close(  );
end 
end 

function windowCloseRequestCallback( obj )
classdiagram.app.core.ClassDiagramWindow.onWindowClosedCallback( obj );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcdy9K5.p.
% Please follow local copyright laws when handling this file.

