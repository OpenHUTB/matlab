classdef ( Abstract )AbstractNotification < handle & matlab.mixin.Heterogeneous

properties ( SetAccess = protected )
Uuid;
Message;
DisplayMessage;
Severity classdiagram.app.core.notifications.Severity =  ...
classdiagram.app.core.notifications.Severity.Info;
Transient logical = true;


Target;
UIMode logical;
CommandLineMode logical;
EditorUuid( 1, 1 )string;
ActionInfoUuid;
UndoRedoState = 0;




Category( 1, 1 )string;

HelpTopicId;
end 

properties ( Access = { ?classdiagram.app.core.notifications.WDFNotifier,  ...
?classdiagram.app.core.notifications.notifications.AbstractNotification,  ...
?classdiagram.app.core.notifications.Batchlist } )

Issued logical;
end 

methods ( Abstract )
createDiagnostic( obj );
getCSH( obj );
end 

methods ( Access = public )
function obj = AbstractNotification( options )
obj.createDiagnostic( options );
obj.Uuid = matlab.lang.internal.uuid;
[ msg, category ] = obj.getDisplayMessageAndCategory;
obj.DisplayMessage = msg;
obj.Category = category;
end 

function help( obj )
[ map_path, topic_id ] = obj.getCSH(  );
if ( ~isempty( map_path ) && ~isempty( topic_id ) )
helpview( map_path, topic_id, 'CSHelpWindow' );
else 

end 
end 

function suppressFcn( obj )
end 


function obj = setUndoRedo( obj, cmdRequest )
R36
obj( 1, 1 );
cmdRequest( 1, 1 )diagram.editor.command.CommandRequest;
end 

import diagram.editor.command.CommandAction;

if cmdRequest.action == CommandAction.undo ...
 || cmdRequest.action == CommandAction.redo
obj.UndoRedoState = cmdRequest.action;
end 

obj.UIMode = ( cmdRequest.actionOrigin ...
 == diagram.editor.command.ActionOrigin.Client );
obj.CommandLineMode = ~obj.UIMode;
end 

function [ msg, category ] = getDisplayMessageAndCategory( obj )
if isa( obj.Message, "MException" )
msg = getReport( obj.Message, 'basic' );
category = obj.Message.identifier;
elseif isa( obj.Message, 'string' ) || isa( obj.Message, 'char' )

msg = obj.Message;
category = obj.Message;
else 
msg = obj.Message.getString(  );
category = obj.Message.Identifier;
end 
end 
end 

methods ( Access = { ?classdiagram.app.core.notifications.WDFNotifier,  ...
?classdiagram.app.core.notifications.notifications.AbstractNotification,  ...
?classdiagram.app.core.notifications.Batchlist } )


function setEditorInfo( obj, actionUuid, actionName, editorUuid,  ...
uiMode, clMode )
obj.EditorUuid = editorUuid;
obj.ActionInfoUuid = actionUuid;
if isempty( obj.UIMode )
obj.UIMode = uiMode;
end 
if isempty( obj.CommandLineMode )
obj.CommandLineMode = clMode;
end 
end 

function setIssued( obj )
obj.Issued = true;
end 
end 

methods ( Sealed )
function bool = eq( varargin )
bool = eq@handle( varargin{ : } );
end 

function bool = ne( varargin )
bool = ne@handle( varargin{ : } );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpFpV1qX.p.
% Please follow local copyright laws when handling this file.

