function[oldSettings,hasUnsavedChanges]=DefaultPushOldSettings(model)
    am=Advisor.Manager.getInstance;
    applicationObj=am.getApplication(...
    'advisor','com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor',...
    'Root',model,'Legacy',true,'MultiMode',false,...
    'token','MWAdvi3orAPICa11');
    MAObj=applicationObj.getRootMAObj();

    activeCheckObj=MAObj.CheckCellArray{MAObj.ActiveCheckID};
    name=activeCheckObj.getID;
    hasUnsavedChanges=MAObj.saveRestorePoint(name,'OldModelSettingsBeforeRunThisCheck');
    oldSettings=model;
end