function isValid=isValidConfigName(configRowObj,newConfigName)









    if~isvarname(newConfigName)
        isValid=false;
        return;
    end
    configNamesList=configRowObj.VarConfigSSSrc.getConfigurationNames();
    configNamesList(configRowObj.VarConfigIdx)=[];
    isValid=~ismember(newConfigName,configNamesList);
end
