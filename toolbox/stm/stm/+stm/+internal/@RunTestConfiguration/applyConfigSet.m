function applyConfigSet(obj,simWatcher)



    if(~isfield(simWatcher.cleanupTestCase,'currConfigSet'))

        [tmpCleanup,tmpOut]=stm.internal.MRT.share.setConfigSet(obj.modelToRun,...
        obj.testSettings.configSet.ConfigName,...
        obj.testSettings.configSet.ConfigRefPath,...
        obj.testSettings.configSet.VarName,...
        obj.testSettings.configSet.ConfigSetOverrideSetting,...
        obj.runningOnMRT);

        obj.addMessages(tmpOut.messages,tmpOut.errorOrLog);

        simWatcher.cleanupTestCase=stm.internal.RunTestConfiguration.copyStructContent(simWatcher.cleanupTestCase,tmpCleanup);
        simWatcher.configName=obj.testSettings.configSet.ConfigName;
        simWatcher.configRefPath=obj.testSettings.configSet.ConfigRefPath;
        simWatcher.configVarName=obj.testSettings.configSet.VarName;
    end
    currConfigSet=getActiveConfigSet(obj.modelToRun);
    obj.out.configSetName=currConfigSet.Name;
    if(~isempty(obj.testSettings.configSet.ConfigRefPath)&&obj.testSettings.configSet.ConfigSetOverrideSetting==2)
        obj.out.configSetName=obj.testSettings.configSet.ConfigRefPath;
    end
end
