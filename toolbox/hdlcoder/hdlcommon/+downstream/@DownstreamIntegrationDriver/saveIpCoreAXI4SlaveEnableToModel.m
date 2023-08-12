function saveIpCoreAXI4SlaveEnableToModel( obj, modelName, setAXI4SlaveEnable )


if ( setAXI4SlaveEnable )
enableAXI4Slave = 'on';
else 
enableAXI4Slave = 'off';
end 

if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'GenerateDefaultAXI4Slave' ), enableAXI4Slave )
hdlset_param( modelName, 'GenerateDefaultAXI4Slave', enableAXI4Slave );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7mN1hV.p.
% Please follow local copyright laws when handling this file.

