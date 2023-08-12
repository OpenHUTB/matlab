function saveIpCoreDataCaptureBufferSizeToModel( obj, modelName, bufferSize )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'IPDataCaptureBufferSize' ), bufferSize )
hdlset_param( modelName, 'IPDataCaptureBufferSize', bufferSize );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvkKl62.p.
% Please follow local copyright laws when handling this file.

