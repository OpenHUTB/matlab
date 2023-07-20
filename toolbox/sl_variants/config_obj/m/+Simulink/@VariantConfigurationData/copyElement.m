function cp=copyElement(obj)





    cp=copyElement@matlab.mixin.Copyable(obj);

    cp.setConfigurations(Simulink.variant.utils.deepCopy(obj.Configurations,'ErrorForNonCopyableHandles',false));
    cp.setConstraints(obj.Constraints);
    cp.setPreferredConfiguration(obj.PreferredConfiguration);
    warnState=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
    cp.setDefaultConfigurationName(obj.DefaultConfigurationName);
    warning(warnState);
    cp.DataDictionaryName=obj.DataDictionaryName;
    cp.DataDictionarySection=obj.DataDictionarySection;
    cp.AreSubModelConfigurationsMigrated=obj.AreSubModelConfigurationsMigrated;
end


