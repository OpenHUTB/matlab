function vcdSource=getVCDOSource(modelName)





    Simulink.variant.reducer.utils.assert(bdIsLoaded(modelName),[modelName,' is not loaded']);
    specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(modelName);
    vcdName=get_param(modelName,'VariantConfigurationObject');
    vcdSource=specialVarsInfoManager.getVariableSource(vcdName);
end
