function saveRDSettingToModel( obj, modelName, referenceDesign )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen || obj.isDynamicWorkflow )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'ReferenceDesign' ), referenceDesign )
hdlset_param( modelName, 'ReferenceDesign', referenceDesign );
end 
modelRDParameterCellFormat = hdlget_param( modelName, 'ReferenceDesignParameter' );
hRD = obj.hIP.getReferenceDesignPlugin;
if ~isempty( hRD ) && ~hRD.isParameterEqual( modelRDParameterCellFormat )
hdlset_param( modelName, 'ReferenceDesignParameter', hRD.getParameterCellFormat );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRjFb2Q.p.
% Please follow local copyright laws when handling this file.

