function saveAXI4SlavePortToPipelineRegisterRatioToModel( obj, modelName, setAXI4SlavePortToPipelineRegisterRatio )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'AXI4SlavePortToPipelineRegisterRatio' ), setAXI4SlavePortToPipelineRegisterRatio )
hdlset_param( modelName, 'AXI4SlavePortToPipelineRegisterRatio', setAXI4SlavePortToPipelineRegisterRatio );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwhQX35.p.
% Please follow local copyright laws when handling this file.

