function buttonOnValueCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    currentConfig=jsondecode(get_param(blockHandle,'Configuration'));


    newOnValue=dialog.getWidgetValue('onValue');
    currentOnValue=currentConfig.components(2).settings.onValue;
    if~strcmp(currentOnValue,newOnValue)
        newOnValueDouble=str2double(newOnValue);
        [success,errormsg]=utils.isValidNumber(newOnValueDouble,...
        sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:PushButtonValue')));
        if~success
            dialog.setWidgetWithError('onValue',...
            DAStudio.UI.Util.Error('onValue','Error',errormsg,[255,0,0,100]));
            return
        end
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'OnValue',newOnValue,'undoable');
    end
    dialog.clearWidgetWithError('onValue');
    dialog.clearWidgetDirtyFlag('onValue');
end
