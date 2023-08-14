function handleModelCompile(modelHandle)







    vcdoObj=Simulink.VariantConfigurationData.getObjectWithMigratedDefConfig(modelHandle);
    if~isempty(vcdoObj)&&~isempty(vcdoObj.DefaultConfigurationName)



        vcdoName=get_param(modelHandle,'VariantConfigurationObject');
        modelName=get_param(modelHandle,'Name');
        warnState=warning('off','backtrace');
        warnStateCleanup=onCleanup(@()warning(warnState));
        warningMessage=[getString(message("Simulink:VariantManager:VCDOHasDefaultConfig",...
        vcdoName,vcdoObj.DefaultConfigurationName)),newline...
        ,getString(message("Simulink:VariantManager:DefaultConfigurationRemoved")),newline...
        ,getString(message("Simulink:VariantManager:ConvertDefaultToPreferredFixitForModel",...
        modelName,vcdoName,vcdoObj.DefaultConfigurationName))];
        warning("Simulink:VariantManager:DefaultConfigurationRemoved",'%s',warningMessage);
    end
end
