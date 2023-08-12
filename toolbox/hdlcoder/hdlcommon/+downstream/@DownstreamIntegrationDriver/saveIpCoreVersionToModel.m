function saveIpCoreVersionToModel( obj, modelName, ipCoreVersion )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'IPCoreVersion' ), ipCoreVersion )
hdlset_param( modelName, 'IPCoreVersion', ipCoreVersion );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeKv4eB.p.
% Please follow local copyright laws when handling this file.

