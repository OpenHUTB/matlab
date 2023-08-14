function variantParametersInfoStruct=getVariantParameters(modelName)






    load_system(modelName);
    specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(modelName);
    variantParametersInfoStruct=specialVarsInfoManager.getVariantParameters();
end
