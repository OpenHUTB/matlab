function retVal=move_with_confirmation(ownerHandle,harnessName)
    try

        harnessDeleteStage=Simulink.output.Stage(...
        DAStudio.message('Simulink:Harness:MoveHarnessStage'),...
        'ModelName',get_param(bdroot(ownerHandle),'name'),...
        'UIMode',true);%#ok

        retVal=0;

        dp=DAStudio.DialogProvider;

        title=DAStudio.message('Simulink:Harness:ConfirmMoveDialogTitle');
        warnStr=DAStudio.message('Simulink:Harness:ConfirmMoveDialogText',harnessName);

        dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
        DAStudio.message('Simulink:Harness:No')},...
        DAStudio.message('Simulink:Harness:No'),...
        @(choice)move_confirmation_cb(choice));

    catch ME

        Simulink.harness.internal.error(ME,true);

        DAStudio.error('Simulink:Harness:MoveHarnessFailed');
    end

    function move_confirmation_cb(choice)
        try
            if strcmp(choice,DAStudio.message('Simulink:Harness:Yes'))
                retVal=1;
                Simulink.harness.move(ownerHandle,harnessName);
            end
        catch ME

            Simulink.harness.internal.error(ME,true);

            DAStudio.error('Simulink:Harness:MoveHarnessFailed');
        end
    end

end

