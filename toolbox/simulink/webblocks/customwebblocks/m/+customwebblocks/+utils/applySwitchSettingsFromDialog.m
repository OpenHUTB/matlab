
function[success,errormsg,batchedUpdate]=applySwitchSettingsFromDialog(dialog,obj,supportsEnums,currentConfig)
    isSlimDialog=strcmpi(dialog.dialogMode,'Slim');
    blockHandle=get(obj.blockObj,'handle');
    errormsg='';
    batchedUpdate=struct;

    [success,newStates]=customwebblocks.utils.validateSwitchStates(obj);

    if~success
        return;
    end

    if supportsEnums
        newEnableEnumDataTypeValue=dialog.getWidgetValue('EnableEnumDataType');
        newEnumDataTypeValue=dialog.getWidgetValue('EnumDataTypeName');
    else
        newEnableEnumDataTypeValue=false;
        newEnumDataTypeValue='';
    end



    if newEnableEnumDataTypeValue
        newValue='on';
        if~isempty(newEnumDataTypeValue)
            [valid,newStates]=customwebblocks.utils.getEnumDefinition(newEnumDataTypeValue);
            if(valid)
                batchedUpdate.EnumeratedDataType=newEnumDataTypeValue;
                batchedUpdate.States=newStates;
                customwebblocks.utils.updateSwitchStates(blockHandle,obj.widgetId,isSlimDialog,batchedUpdate.States);
            else
                errormsg=DAStudio.message('SimulinkHMI:dialogs:InvalidEnumDataType');
                success=false;
                return
            end
        end
        batchedUpdate.UseEnumeratedDataType=newValue;
    else
        newValue='off';
        batchedUpdate.EnumeratedDataType=newEnumDataTypeValue;
        batchedUpdate.UseEnumeratedDataType=newValue;
        batchedUpdate.States=newStates;
        customwebblocks.utils.updateSwitchStates(blockHandle,obj.widgetId,isSlimDialog,newStates)
    end

    dialog.enableApplyButton(false,false);
end
