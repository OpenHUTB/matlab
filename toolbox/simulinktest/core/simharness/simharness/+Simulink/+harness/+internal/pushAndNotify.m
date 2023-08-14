function pushAndNotify(harness)

    res=Simulink.harness.internal.showPushImportedHarnessModalAlertIfNecessary(harness.name);
    if~res
        return;
    end

    res=Simulink.harness.internal.showPushInterfaceChangedModalAlertIfNecessary(harness.name);
    if~res
        return;
    end


    harnessPushStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:PushHarnessStage'),...
    'ModelName',harness.name,...
    'UIMode',true);%#ok


    editor=Simulink.harness.internal.findHarnessEditor(harness.name);

    try
        Simulink.harness.push(harness.ownerHandle,harness.name);
        editor.deliverInfoNotification('Simulink:Harness:push',...
        DAStudio.message('Simulink:Harness:PushHarnessSuccessNotification',harness.name,...
        harness.ownerFullPath,harness.model));
    catch ME

        Simulink.harness.internal.error(ME,true);


        msg=DAStudio.message('Simulink:Harness:PushHarnessFailedNotification',...
        harness.name,harness.ownerFullPath,harness.model);
        editor.deliverWarnNotification('Simulink:Harness:push',msg);

    end
end
