function val=get_makertwsettings(modelName,settingName)





    h=coder.internal.ModelCodegenMgr.getInstance(modelName);
    if isempty(h)
        DAStudio.error('RTW:buildProcess:loadObjectHandleError',...
        'ModelCodegenMgr');
    end

    val=eval(['h.',settingName]);
