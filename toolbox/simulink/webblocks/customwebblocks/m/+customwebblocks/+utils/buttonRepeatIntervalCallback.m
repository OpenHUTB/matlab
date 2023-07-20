function buttonRepeatIntervalCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newRepeatInterval=dialog.getWidgetValue('repeatInterval');
    if ischar(newRepeatInterval)
        currentRepeatInterval=currentConfig.components(2).settings.repeatInterval;
        if~strcmp(currentRepeatInterval,newRepeatInterval)
            roundedRepeatInterval=round(str2double(newRepeatInterval));
            success=~isnan(roundedRepeatInterval)&&roundedRepeatInterval>=0;
            if~success
                errormsg=DAStudio.message('SimulinkHMI:dialogs:RepeatIntervalError');
                dialog.setWidgetWithError('repeatInterval',...
                DAStudio.UI.Util.Error('RepeatInterval','Error',errormsg,[255,0,0,100]));
                return
            end
            roundedRepeatIntervalStr=num2str(roundedRepeatInterval);
            dialog.setWidgetValue('repeatInterval',roundedRepeatIntervalStr);
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'RepeatInterval',roundedRepeatIntervalStr,'undoable');
        end
        dialog.clearWidgetWithError('repeatInterval');
        dialog.clearWidgetDirtyFlag('repeatInterval');
    end
end

