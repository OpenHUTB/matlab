function rebuildAndNotify(harness)

    res=Simulink.harness.internal.showRebuildInterfaceChangedModalAlertIfNecessary(harness.name);
    if~res
        return;
    end


    harnessRebuildStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:RebuildHarnessStage'),...
    'ModelName',harness.name,...
    'UIMode',true);%#ok

    try
        Simulink.harness.rebuild(harness.ownerHandle,harness.name);


        editor=Simulink.harness.internal.findHarnessEditor(harness.name);


        msgid=editor.getActiveNotification();
        if strcmp(msgid,'Simulink:Harness:rebuild')
            editor.closeNotificationByMsgID(msgid);
        end

        if strcmp(harness.origSrc,Simulink.harness.internal.TestHarnessSourceTypes.REACTIVE_TEST.name)

            editor.deliverInfoNotification('Simulink:Harness:rebuild',...
            DAStudio.message('Simulink:Harness:RebuildHarnessSuccessNotificationTestSequence',...
            harness.name,...
            harness.ownerFullPath,...
            harness.origSrc));
        elseif strcmp(harness.origSrc,Simulink.harness.internal.TestHarnessSourceTypes.STATEFLOW.name)
            editor.deliverInfoNotification('Simulink:Harness:rebuild',...
            DAStudio.message('Simulink:Harness:RebuildHarnessSuccessNotificationStateflowChart',...
            harness.name,...
            harness.ownerFullPath,...
            harness.origSrc));
        else
            editor.deliverInfoNotification('Simulink:Harness:rebuild',...
            DAStudio.message('Simulink:Harness:RebuildHarnessSuccessNotification',...
            harness.name,...
            harness.ownerFullPath,...
            harness.origSrc,...
            harness.origSink));
        end

    catch ME

        Simulink.harness.internal.error(ME,true);

        editor=Simulink.harness.internal.findHarnessEditor(harness.name);


        msg=DAStudio.message('Simulink:Harness:RebuildHarnessFailedNotification',...
        harness.name,harness.ownerFullPath);


        msgid=editor.getActiveNotification();
        if strcmp(msgid,'Simulink:Harness:rebuild')
            editor.closeNotificationByMsgID(msgid);
        end

        editor.deliverWarnNotification('Simulink:Harness:rebuild',msg);
    end
end
