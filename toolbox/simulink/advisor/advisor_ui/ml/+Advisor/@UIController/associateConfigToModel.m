function result=associateConfigToModel(this)
    result=[];
    ConfigFilePath=this.maObj.ConfigFilePath;
    ModelAdvisor.setModelConfiguration(this.rootmodel,ConfigFilePath);
    cs=getActiveConfigSet(this.rootmodel);
    configset.highlightParameter(cs,'ModelAdvisorConfigurationFile');
end