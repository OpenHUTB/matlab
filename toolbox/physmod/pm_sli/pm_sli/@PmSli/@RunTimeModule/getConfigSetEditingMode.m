function editingMode=getConfigSetEditingMode(this,ccObj)






    configData=RunTimeModule_config;

    if~isempty(ccObj)
        editingMode=get(ccObj,configData.EditingMode.PropertyName);
    else
        pm_error(configData.Error.CannotGetEditingModeNoSource_msgid);
    end



