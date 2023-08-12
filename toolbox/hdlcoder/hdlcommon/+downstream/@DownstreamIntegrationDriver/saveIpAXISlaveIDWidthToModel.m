function saveIpAXISlaveIDWidthToModel( obj, modelName, GUIIDWidthValue )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'AXI4SlaveIDWidth' ), GUIIDWidthValue )
hdlset_param( modelName, 'AXI4SlaveIDWidth', GUIIDWidthValue );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqSklEG.p.
% Please follow local copyright laws when handling this file.

