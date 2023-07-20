function switchEnumCallback(dialog,obj)

    success=false;
    batchedUpdate=[];
    isSlimDialog=strcmpi(dialog.dialogMode,'Slim');
    blockHandle=get(obj.blockObj,'handle');
    newEnableEnumDataTypeValue=dialog.getWidgetValue('UseEnumDataType');
    newEnumDataTypeValue=dialog.getWidgetValue('EnumDataType');



    if newEnableEnumDataTypeValue
        newValue='on';
        dialog.setEnabled('EnumDataType',true);
        if~isempty(newEnumDataTypeValue)
            [success,newStates]=customwebblocks.utils.getEnumDefinition(newEnumDataTypeValue);
            if(success)
                batchedUpdate.EnumeratedDataType=newEnumDataTypeValue;
                batchedUpdate.States=newStates;
                customwebblocks.utils.updateSwitchStates(blockHandle,obj.widgetId,isSlimDialog,batchedUpdate.States);
                dialog.clearWidgetDirtyFlag('EnumDataType');
            else
                errormsg=DAStudio.message('SimulinkHMI:dialogs:InvalidEnumDataType');
                if isSlimDialog
                    dialog.setWidgetWithError('EnumDataType',...
                    DAStudio.UI.Util.Error('EnumDataType','Error',errormsg,[255,0,0,100]));
                end
                return
            end
        else


            dialog.setWidgetDirty('EnumDataType');
        end
        batchedUpdate.UseEnumeratedDataType=newValue;
    else
        success=true;
        newValue='off';
        dialog.setEnabled('EnumDataType',false);
        batchedUpdate.EnumeratedDataType=newEnumDataTypeValue;
        batchedUpdate.UseEnumeratedDataType=newValue;
        [~,batchedUpdate.States]=customwebblocks.utils.validateSwitchStates(obj);
        customwebblocks.utils.updateSwitchStates(blockHandle,obj.widgetId,isSlimDialog,batchedUpdate.States);
    end
    if success&&isSlimDialog
        dialog.clearWidgetWithError('EnumDataType')
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'batchedUndoableParamsUpdate',jsonencode(batchedUpdate),'undoable');
    end
end
