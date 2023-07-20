function vcdoObj=getConfigurationDataNoThrow(modelName)









    try
        vcdoObj=Simulink.VariantConfigurationData.getFor(modelName);
    catch

        vcdoObj=[];
    end
end
