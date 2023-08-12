function saveIpCoreNameToModel( obj, modelName, ipCoreName )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'IPCoreName' ), ipCoreName )
hdlset_param( modelName, 'IPCoreName', ipCoreName );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwaMzd5.p.
% Please follow local copyright laws when handling this file.

