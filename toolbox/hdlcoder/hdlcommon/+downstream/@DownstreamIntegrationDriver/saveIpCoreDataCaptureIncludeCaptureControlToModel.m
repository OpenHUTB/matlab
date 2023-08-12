function saveIpCoreDataCaptureIncludeCaptureControlToModel( obj, modelName, enableCaptureControl )

if ( enableCaptureControl )
enableCaptureControl = 'on';
else 
enableCaptureControl = 'off';
end 

if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
hdlset_param( modelName, 'IncludeDataCaptureControlLogicEnable', enableCaptureControl );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKxoq1h.p.
% Please follow local copyright laws when handling this file.

