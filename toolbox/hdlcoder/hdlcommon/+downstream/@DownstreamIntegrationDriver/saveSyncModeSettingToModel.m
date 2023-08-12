function saveSyncModeSettingToModel( obj, modelName, syncMode )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen || obj.isXPCWorkflow ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'ProcessorFPGASynchronization' ), syncMode )
hdlset_param( modelName, 'ProcessorFPGASynchronization', syncMode );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUZHfXD.p.
% Please follow local copyright laws when handling this file.

