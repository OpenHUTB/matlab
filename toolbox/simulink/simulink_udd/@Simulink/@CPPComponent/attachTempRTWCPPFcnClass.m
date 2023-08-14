function attachTempRTWCPPFcnClass(modelName)



    if bdIsLoaded(modelName)&&hasProp(getActiveConfigSet(modelName),'cacheRTWCPPFcnClass')
        isDirty=get_param(modelName,'Dirty');
        cleanupObj=onCleanup(@()set_param(modelName,'Dirty',isDirty));

        set_param(modelName,'cacheRTWCPPFcnClass',get_param(modelName,'RTWCPPFcnClass'));

        tempRtwCppFcnClass=RTW.ModelCPPDefaultClass;
        tempRtwCppFcnClass.isTemp=true;
        tempRtwCppFcnClass.attachToModel(modelName);
        tempRtwCppFcnClass.setDefaultClassName();
        tempRtwCppFcnClass.setDefaultStepMethodName();
    end
