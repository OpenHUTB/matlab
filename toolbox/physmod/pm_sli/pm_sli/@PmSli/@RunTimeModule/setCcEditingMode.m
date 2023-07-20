function success=setCcEditingMode(this,ccObj,requestedMode)








    configData=RunTimeModule_config;
    set(ccObj,configData.EditingMode.PropertyName,requestedMode);




