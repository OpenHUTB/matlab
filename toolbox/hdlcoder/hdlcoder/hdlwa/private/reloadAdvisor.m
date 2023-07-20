function reloadAdvisor




    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    modelName=MAObj.modelName;
    if isa(MAObj,'Simulink.ModelAdvisor')

        if~isa(MAObj.ConfigUIWindow,'DAStudio.Explorer')
            warnmsg=DAStudio.message('HDLShared:hdldialog:HDLWAWarnSwitchSubsystem');
            response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
            DAStudio.message('Simulink:tools:MALoad'),...
            DAStudio.message('Simulink:tools:MACancel'),...
            DAStudio.message('Simulink:tools:MACancel'));
            if~strcmp(response,DAStudio.message('Simulink:tools:MALoad'))
                return;
            end
        end
    end






    t=timer;
    t.Name='SwitchSubsystemCallBackTimer';
    t.StartDelay=1;
    userData.modelName=modelName;
    t.UserData=userData;


    t.TimerFcn=@loc_ReloadAdvisor;
    start(t);
end

function loc_ReloadAdvisor(timerobj,varargin)
    userData=timerobj.UserData;
    stop(timerobj);
    delete(timerobj);


    hdladvisor(userData.modelName,'systemselector');
end


