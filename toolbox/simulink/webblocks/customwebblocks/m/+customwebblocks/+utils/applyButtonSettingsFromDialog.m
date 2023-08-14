
function[success,errormsg,batchedUpdate]=applyButtonSettingsFromDialog(dialog,obj,currentConfig)
    isSlimDialog=strcmpi(dialog.dialogMode,'Slim');
    blockHandle=get(obj.blockObj,'handle');
    success=true;
    errormsg='';
    batchedUpdate=struct;



    newButtonTypeIndex=dialog.getWidgetValue('buttonType');
    switch newButtonTypeIndex
    case 0
        newButtonType='momentary';
    case 1
        newButtonType='latch';
    end
    currentButtonType=currentConfig.components(2).settings.buttonType;
    if~strcmp(currentButtonType,newButtonType)
        batchedUpdate.ButtonType=newButtonType;
    end
    dialog.clearWidgetDirtyFlag('buttonType');


    newButtonText=dialog.getWidgetValue('buttonText');


    newButtonTextMultipleValues=dialog.getWidgetValue('buttonTextMultipleValues');
    if dialog.isVisible('buttonTextMultipleValues')&&...
        ~isempty(newButtonTextMultipleValues)
        newButtonText=newButtonTextMultipleValues;
        shouldUpdate=true;
    else
        defaultState=currentConfig.components(2).settings.states(1);
        currentButtonText=defaultState.label.text.content;
        shouldUpdate=~strcmp(currentButtonText,newButtonText);
    end
    if shouldUpdate
        batchedUpdate.ButtonText=newButtonText;
    end
    dialog.clearWidgetDirtyFlag('buttonText');
    dialog.clearWidgetDirtyFlag('buttonTextMultipleValues');


    newClickFcn=dialog.getWidgetValue('clickFcn');
    if ischar(newClickFcn)
        currentClickFcn=currentConfig.components(2).settings.clickFcn;
        if~strcmp(currentClickFcn,newClickFcn)
            batchedUpdate.ClickFcn=newClickFcn;
        end
        dialog.clearWidgetDirtyFlag('clickFcn');
    end


    newPressFcn=dialog.getWidgetValue('pressFcn');
    if ischar(newPressFcn)
        currentPressFcn=currentConfig.components(2).settings.pressFcn;
        if~strcmp(currentPressFcn,newPressFcn)
            batchedUpdate.PressFcn=newPressFcn;
        end
        dialog.clearWidgetDirtyFlag('pressFcn');
    end


    newPressDelay=dialog.getWidgetValue('pressDelay');
    if ischar(newPressDelay)
        currentPressDelay=currentConfig.components(2).settings.pressDelay;
        if~strcmp(currentPressDelay,newPressDelay)
            roundedPressDelay=round(str2double(newPressDelay));
            success=~isnan(roundedPressDelay)&&roundedPressDelay>=0;
            if~success
                errormsg=DAStudio.message('SimulinkHMI:dialogs:PressDelayError');
                if isSlimDialog
                    dialog.setWidgetWithError('pressDelay',...
                    DAStudio.UI.Util.Error('PressDelay','Error',errormsg,[255,0,0,100]));
                end
                return
            end
            roundedPressDelayStr=num2str(roundedPressDelay);
            dialog.setWidgetValue('pressDelay',roundedPressDelayStr);
            batchedUpdate.PressDelay=roundedPressDelayStr;
        end
        dialog.clearWidgetWithError('pressDelay');
        dialog.clearWidgetDirtyFlag('pressDelay');
    end


    newRepeatInterval=dialog.getWidgetValue('repeatInterval');
    if ischar(newRepeatInterval)
        currentRepeatInterval=currentConfig.components(2).settings.repeatInterval;
        if~strcmp(currentRepeatInterval,newRepeatInterval)
            roundedRepeatInterval=round(str2double(newRepeatInterval));
            success=~isnan(roundedRepeatInterval)&&roundedRepeatInterval>=0;
            if~success
                errormsg=DAStudio.message('SimulinkHMI:dialogs:RepeatIntervalError');
                if isSlimDialog
                    dialog.setWidgetWithError('repeatInterval',...
                    DAStudio.UI.Util.Error('RepeatInterval','Error',errormsg,[255,0,0,100]));
                end
                return
            end
            roundedRepeatIntervalStr=num2str(roundedRepeatInterval);
            dialog.setWidgetValue('repeatInterval',roundedRepeatIntervalStr);
            batchedUpdate.RepeatInterval=roundedRepeatIntervalStr;
        end
        dialog.clearWidgetWithError('repeatInterval');
        dialog.clearWidgetDirtyFlag('repeatInterval');
    end



    customType=get_param(blockHandle,'CustomType');
    if strcmp(customType,'Push Button')


        newOnValue=dialog.getWidgetValue('onValue');
        currentOnValue=currentConfig.components(2).settings.onValue;
        if~strcmp(currentOnValue,newOnValue)
            newOnValueDouble=str2double(newOnValue);
            [success,errormsg]=utils.isValidNumber(newOnValueDouble,...
            sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:PushButtonValue')));
            if~success
                if isSlimDialog
                    dialog.setWidgetWithError('onValue',...
                    DAStudio.UI.Util.Error('onValue','Error',errormsg,[255,0,0,100]));
                end
                return
            end
            batchedUpdate.OnValue=newOnValueDouble;
        end
        dialog.clearWidgetWithError('onValue');
        dialog.clearWidgetDirtyFlag('onValue');
    end
    dialog.enableApplyButton(false,false);
end
