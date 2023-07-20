
function[success,errormsg]=applyLampSettingsFromDialog(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    success=true;
    errormsg='';
    updatedSettings=[];


    newStateValueTypeIndex=dialog.getWidgetValue('stateValueType');
    switch newStateValueTypeIndex
    case 0
        newStateValueType='Discrete';
    case 1
        newStateValueType='Range';
    end
    currentStateValueType=get_param(blockHandle,'StateValueType');
    if~strcmp(currentStateValueType,newStateValueType)
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'StateValueType',newStateValueType,'undoable');
        updatedSettings.stateValueType=newStateValueTypeIndex;
    end
    dialog.clearWidgetDirtyFlag('stateValueType');


    if~isempty(updatedSettings)
        lampDlgs=obj.getOpenDialogs(true);
        for j=1:length(lampDlgs)
            if~isequal(dialog,lampDlgs{j})
                customwebblocks.utils.updateDialogSettings(lampDlgs{j},updatedSettings);
            end
        end
    end
    dialog.enableApplyButton(false,false);
end