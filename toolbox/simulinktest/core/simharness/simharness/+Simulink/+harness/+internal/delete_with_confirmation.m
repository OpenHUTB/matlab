function retVal=delete_with_confirmation(ownerHandle,harnessName)
    try

        harnessDeleteStage=Simulink.output.Stage(...
        DAStudio.message('Simulink:Harness:DeleteHarnessStage'),...
        'ModelName',get_param(bdroot(ownerHandle),'name'),...
        'UIMode',true);%#ok

        retVal=0;

        dp=DAStudio.DialogProvider;

        title=DAStudio.message('Simulink:Harness:ConfirmDeleteDialogTitle');
        warnStr=DAStudio.message('Simulink:Harness:ConfirmDeleteDialogText',harnessName);

        dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
        DAStudio.message('Simulink:Harness:No')},...
        DAStudio.message('Simulink:Harness:No'),...
        @(choice)delete_confirmation_cb(choice));

    catch ME

        Simulink.harness.internal.error(ME,true);






        DAStudio.error('Simulink:Harness:DeleteHarnessFailed');
    end

    function delete_confirmation_cb(choice)
        try
            if strcmp(choice,DAStudio.message('Simulink:Harness:Yes'))
                retVal=1;
                Simulink.harness.delete(ownerHandle,harnessName);
            end
        catch ME

            Simulink.harness.internal.error(ME,true);






            DAStudio.error('Simulink:Harness:DeleteHarnessFailed');
        end
    end

end

