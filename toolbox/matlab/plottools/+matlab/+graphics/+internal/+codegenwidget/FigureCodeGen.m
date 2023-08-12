classdef FigureCodeGen < handle






properties ( Access = private, Constant )
CodeGenManagerKey = '/Codegen';
EDITOR_LOADED = '/figure/codegen/editorLoaded';
UPDATE_CODE_CONTENT = '/figure/codegen/updateContent';
CLEAR_BUTTON_CHANNEL = '/figure/codegen/clearGeneratedCode';
end 

properties ( Transient, NonCopyable, Hidden )
ChannelI
Code
isWidgetVisible
end 

properties ( Access = protected, Transient, NonCopyable, Hidden )
ViewReadyListener;
ClearButtonActionListener;
end 

properties ( Dependent = true )
Channel
end 

events ( Hidden )
CodeGenWidgetClearButtonAction
end 

methods 
function channel = get.Channel( obj )
if ~isempty( obj.ChannelI )
channel = obj.ChannelI;
return ;
end 


persistent uuid;
if isempty( uuid )
uuid = 0;
end 
uuid = uuid + 1;

channel = sprintf( '%s%d', obj.CodeGenManagerKey, uuid );
obj.ChannelI = channel;
end 

function set.Channel( obj, value )
obj.ChannelI = value;
end 
end 

methods 
function obj = FigureCodeGen( ChannelId )
R36
ChannelId{ string } = "";
end 

if ~isempty( ChannelId )
obj.Channel = ChannelId;
end 


obj.setup;
end 

function delete( obj )
if ~isempty( obj.ViewReadyListener )
obj.ViewReadyListener = [  ];
end 
if ~isempty( obj.ClearButtonActionListener )
obj.ClearButtonActionListener = [  ];
end 
end 
end 

methods ( Access = protected )
function setup( obj )

channel = obj.Channel;

obj.ViewReadyListener = message.subscribe( strcat( obj.EDITOR_LOADED, channel ), @( msg )obj.updateCode( msg ), 'autoUnsub', true, 'enableDebugger', false );
obj.ClearButtonActionListener = message.subscribe( strcat( obj.CLEAR_BUTTON_CHANNEL, channel ), @( msg )obj.clearButtonAction( msg ), 'autoUnsub', true, 'enableDebugger', false );
end 
end 

methods 
function setCode( obj, code )


if isempty( code )
code = strcat( "% ", getString( message( 'figuredatatools:figurecodegenwidgetjs:EmptyCodeGenerationString' ) ) );
end 
channel = obj.Channel;
obj.Code = code;
message.publish( strcat( obj.UPDATE_CODE_CONTENT, channel ), code );
obj.isWidgetVisible = true;
end 

function updateCode( obj, ~ )





fcm = matlab.graphics.internal.codegenwidget.FigureCodeGenManager.getInstance(  );
code = fcm.CodeGenMap( obj.Channel ).Code;
if isempty( code )
code = strcat( "% ", getString( message( 'figuredatatools:figurecodegenwidgetjs:EmptyCodeGenerationString' ) ) );
end 
message.publish( strcat( obj.UPDATE_CODE_CONTENT, obj.Channel ), code );
obj.isWidgetVisible = true;
end 

function clearButtonAction( obj, ~ )




notify( obj, 'CodeGenWidgetClearButtonAction' );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLfeqvP.p.
% Please follow local copyright laws when handling this file.

