function result=restoreDefaultConfig(this)


    modelName=bdroot(this.maObj.SystemName);
    cs=getActiveConfigSet(modelName);
    if cs.isValidParam('ModelAdvisorConfigurationFile')&&~isempty(get_param(modelName,'ModelAdvisorConfigurationFile'))
        set_param(modelName,'ModelAdvisorConfigurationFile','');
    end
    this.maObj.activateConfiguration('',true);
    result=[];
end