function targetSelectionCallback(hObj,hDlg,tag,~)





    hCS=hObj.getParent;
    modelName=hCS.getModel;
    newSelection=hDlg.getComboBoxText(tag);

    if isequal(newSelection,'Get more...')
        idx=hObj.getMatchTargetIdx(hObj.TargetExtensionPlatform,hObj.getTargetList());
        hDlg.setWidgetValue(tag,idx);
        matlab.addons.supportpackage.internal.explorer.showSupportPackagesForBaseProducts('SL','tripwire');

        return
    end

    if isequal(newSelection,get_param(hCS,'TargetExtensionPlatform'))
        return
    end

    set_param(hCS,'TargetExtensionPlatform',newSelection);





    if~isequal(newSelection,'None')
        fname=realtime.getDataFileName('targetInfo',newSelection);
        targetInfo=realtime.TargetInfo(fname,newSelection,modelName);
        set_param(hCS,'ProdHWDeviceType',targetInfo.ProdHWDeviceType);
        set_param(modelName,'ExtModeTrigDuration',targetInfo.ExtModeTrigDuration);
        set_param(hCS,'ExtModeTransport',targetInfo.ExtModeTransport);
        if~isempty(targetInfo.ExtModeMexArgsInit)
            set_param(hCS,'ExtModeMexArgs',targetInfo.ExtModeMexArgsInit);
        end
        realtime.setModelForRTT(hCS,true);
    end

    set_param(hCS,'TargetExtensionData','');
end
