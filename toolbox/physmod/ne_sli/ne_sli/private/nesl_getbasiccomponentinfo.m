function[messageTitle,description]=nesl_getbasiccomponentinfo(componentName)









    [messageTitle,description]=...
    simscape.internal.dialog.getBasicComponentInfo(componentName);


end
