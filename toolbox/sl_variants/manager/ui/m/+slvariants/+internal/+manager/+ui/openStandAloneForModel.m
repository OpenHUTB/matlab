function openStandAloneForModel(modelName)







    vcdoObj=Simulink.VariantConfigurationData.getFor(modelName);
    if~isempty(vcdoObj)
        vcdoName=get_param(modelName,'VariantConfigurationObject');
        openvar(vcdoName,vcdoObj);
    end
end