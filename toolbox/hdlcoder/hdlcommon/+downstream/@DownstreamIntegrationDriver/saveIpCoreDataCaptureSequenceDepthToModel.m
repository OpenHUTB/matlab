function saveIpCoreDataCaptureSequenceDepthToModel( obj, modelName, sequenceDepth )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'IPDataCaptureSequenceDepth' ), sequenceDepth )
hdlset_param( modelName, 'IPDataCaptureSequenceDepth', sequenceDepth );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpk5ksUZ.p.
% Please follow local copyright laws when handling this file.

