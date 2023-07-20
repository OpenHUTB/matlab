function buttonPressDelayCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newPressDelay=dialog.getWidgetValue('pressDelay');
    if ischar(newPressDelay)
        currentPressDelay=currentConfig.components(2).settings.pressDelay;
        if~strcmp(currentPressDelay,newPressDelay)
            roundedPressDelay=round(str2double(newPressDelay));
            success=~isnan(roundedPressDelay)&&roundedPressDelay>=0;
            if~success
                errormsg=DAStudio.message('SimulinkHMI:dialogs:PressDelayError');
                dialog.setWidgetWithError('pressDelay',...
                DAStudio.UI.Util.Error('PressDelay','Error',errormsg,[255,0,0,100]));
                return
            end
            roundedPressDelayStr=num2str(roundedPressDelay);
            dialog.setWidgetValue('pressDelay',roundedPressDelayStr);
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'PressDelay',roundedPressDelayStr,'undoable');
        end
        dialog.clearWidgetWithError('pressDelay');
        dialog.clearWidgetDirtyFlag('pressDelay');
    end
end

