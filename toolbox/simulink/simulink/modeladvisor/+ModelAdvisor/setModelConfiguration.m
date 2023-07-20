



function setModelConfiguration(ModelName,ConfigFilePath)


    if~exist(ConfigFilePath,'file')
        DAStudio.error('ModelAdvisor:engine:ConfigurationFileNotFound',ConfigFilePath);
    end






    cs=getActiveConfigSet(ModelName);
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet;
    end
    maconfigset=ModelAdvisor.ConfigsetCC;
    cs.attachComponent(maconfigset);
    cs.set_param('ModelAdvisorConfigurationFile',ConfigFilePath);