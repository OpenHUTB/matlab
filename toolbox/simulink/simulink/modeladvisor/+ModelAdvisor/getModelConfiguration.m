



function configFile=getModelConfiguration(ModelName)
    configFile='';
    cs=getActiveConfigSet(bdroot(ModelName));
    if~cs.isValidParam('ModelAdvisorConfigurationFile')
        return
    end


    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet;
    end

    maconfigset=cs.getComponent('Model Advisor');
    if isempty(maconfigset)
        DAStudio.error('ModelAdvisor:engine:NoConfigurationForModel',bdroot(ModelName));
    end
    configFile=maconfigset.ModelAdvisorConfigurationFile;