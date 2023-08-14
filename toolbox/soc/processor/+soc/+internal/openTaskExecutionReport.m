function openTaskExecutionReport(modelName)




    persistent msgBoxFig
    sdiRun=soc.internal.sdi.getLastSDIRunForModel(modelName);
    if~isempty(sdiRun)
        try


            if~isempty(find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager'))
                taskData=socTaskTimes(modelName,sdiRun.Name,'SuppressPlot');
                coreData=socHardwareUsage(modelName,sdiRun.Name,'SuppressPlot');
            elseif get_param(modelName,'UseSoCProfilerForTargets')
                tsn=codertarget.target.getTargetShortName(getActiveConfigSet(modelName));
                taskData=codertarget.(tsn).socTaskTimes(modelName,sdiRun.Name);
                coreData=codertarget.(tsn).socHardwareUsage(modelName,sdiRun.Name);
            else
                assert(false,'Task Manager block not found in the model');
            end
            if~isempty(taskData)&&~isempty(coreData)
                socTaskExecutionReport(modelName,sdiRun,taskData,coreData);
            else
                msg=message('soc:scheduler:CannotOpenExecutionReport',modelName).getString;
                msgBoxFig=showErrorBox(msg,msgBoxFig);
            end
        catch e
            msgBoxFig=showErrorBox(e.message,msgBoxFig);
        end
    else
        msg=message('soc:scheduler:NoRunFoundForThisModel',modelName).getString;
        msgBoxFig=showErrorBox(msg,msgBoxFig);
    end
end


function msgBoxFig=showErrorBox(msg,msgBoxFig)
    if~isempty(msgBoxFig)&&isvalid(msgBoxFig)
        close(msgBoxFig);
    end
    msgBoxFig=msgbox(msg,'Error');
end