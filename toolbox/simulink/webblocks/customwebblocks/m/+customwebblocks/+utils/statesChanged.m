function statesChanged(dlg,obj,widgetId,model,tag)
    hBlk=get(obj.getBlock(),'Handle');
    isSlimDialog=strcmpi(dlg.dialogMode,'Slim');
    [success,newStates]=customwebblocks.utils.validateSwitchStates(obj);
    if success
        DAStudio.CustomWebBlocks.notifyWebFrontEnd(hBlk,'States',jsonencode(newStates),'undoable');
        buttonDlgs=obj.getOpenDialogs;
        for j=1:length(buttonDlgs)
            if~isequal(dlg,buttonDlgs{j})
                customwebblocks.utils.updateSwitchStates(hBlk,obj.widgetId,isSlimDialog,newStates);
            end
        end
    end
end

