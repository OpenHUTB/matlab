function saveIpCoreAXI4RegisterReadbackToModel( obj, modelName, setAXI4RegisterReadback )


if ( setAXI4RegisterReadback )
enableAXI4RegisterReadback = 'on';
else 
enableAXI4RegisterReadback = 'off';
end 

if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'AXI4RegisterReadback' ), enableAXI4RegisterReadback )
hdlset_param( modelName, 'AXI4RegisterReadback', enableAXI4RegisterReadback );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVK3X6w.p.
% Please follow local copyright laws when handling this file.

