function[configSelectionFound,configName]=getSubModelConfig(subModelName,configuration)




    subModelConfigs=configuration.SubModelConfigurations;

    configName='';
    configSelectionFound=false;

    if~isempty(subModelConfigs)
        mi=Simulink.variant.utils.searchInListPropByField(configuration,'SubModelConfigurations','ModelName',subModelName);
        if~isempty(mi)
            configSelectionFound=true;
            configName=subModelConfigs(mi).ConfigurationName;
        end
    end

end
