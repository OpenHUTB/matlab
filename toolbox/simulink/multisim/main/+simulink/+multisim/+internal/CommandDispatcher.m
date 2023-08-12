classdef CommandDispatcher < handle
properties ( Access = private )
TargetDataModel
MessageSubscription
TargetModelHandle
end 

methods 
function obj = CommandDispatcher( channelName, targetDataModel, targetModelHandle )
R36
channelName( 1, 1 )string
targetDataModel( 1, 1 )mf.zero.Model
targetModelHandle( 1, 1 )double
end 

obj.TargetDataModel = targetDataModel;
obj.MessageSubscription = message.subscribe( channelName, @obj.dispatchCommand );
obj.TargetModelHandle = targetModelHandle;
end 

function delete( obj )
message.unsubscribe( obj.MessageSubscription );
end 
end 

methods ( Access = private )
function dispatchCommand( obj, msg )
switch msg.Type
case "Execute"
obj.handleExecute( msg );

case "ChangeProperty"
obj.handlePropertyChange( msg );
end 
end 

function handleExecute( obj, msg )
targetElement = obj.TargetDataModel.findElement( msg.TargetUuid );
targetElementMetaClass = targetElement.StaticMetaClass;

executeArgs = cell.empty;

if isfield( msg, "ExecuteArgs" )
msg.ExecuteArgs = [ executeArgs, msg.ExecuteArgs ];
for i = 1:numel( msg.ExecuteArgs )
if isstruct( msg.ExecuteArgs{ i } )
executeArgsI = namedargs2cell( msg.ExecuteArgs{ i } );
else 
executeArgsI = msg.ExecuteArgs{ i };
end 
executeArgs = [ executeArgs, executeArgsI ];
end 
end 

simulink.multisim.internal.utils.( targetElementMetaClass.name ).( msg.Command )( obj.TargetDataModel,  ...
targetElement, obj.TargetModelHandle, executeArgs{ : } );
end 

function handlePropertyChange( obj, msg )
element = obj.TargetDataModel.findElement( msg.ownerUuid );
oldValue = element.( msg.Name );
element.( msg.Name ) = msg.Value;

elementMetaClass = element.StaticMetaClass;
validatorFcn = "simulink.multisim.internal.utils." + elementMetaClass.name + ".validateProperty";
if which( validatorFcn )
validatorFcnHdl = str2func( validatorFcn );
validatorFcnHdl( obj.TargetDataModel, element, msg.Name, oldValue );
end 

if isfield( msg, "RequiresCallback" ) && msg.RequiresCallback
simulink.multisim.internal.utils.( elementMetaClass.name ).handlePropertyChange(  ...
obj.TargetDataModel, element, msg.Name, obj.TargetModelHandle );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqSlbwB.p.
% Please follow local copyright laws when handling this file.

