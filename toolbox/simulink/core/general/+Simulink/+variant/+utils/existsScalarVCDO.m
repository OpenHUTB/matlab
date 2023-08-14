function[varExists,section]=existsScalarVCDO(modelName,varName)



    [varExists,varIsVarConfigDataObject,section]=...
    Simulink.variant.utils.existsVCDO(modelName,varName);



    varExists=varExists&&varIsVarConfigDataObject&&...
    Simulink.variant.utils.evalExpressionInSection(...
    modelName,['isscalar(',varName,')'],section);
end
