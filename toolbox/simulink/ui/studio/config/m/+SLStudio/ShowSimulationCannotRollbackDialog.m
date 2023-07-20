function ShowSimulationCannotRollbackDialog
    mlock;
    persistent dp;
    persistent dlg;
    if isa(dlg,'DAStudio.Dialog')
        dlg.show
    else
        if~isa(dp,'DAStudio.DialogProvider')
            dp=DAStudio.DialogProvider;
        end
        msg=DAStudio.message('Simulink:Commands:InsufficientSavedHistoryToStepBackward');
        title=DAStudio.message('Simulink:studio:SimulationStepperWarn');
        dlg=dp.msgbox(msg,title,true);

    end
