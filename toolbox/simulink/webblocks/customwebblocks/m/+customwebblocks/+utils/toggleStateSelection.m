function toggleStateSelection(blockHandle,selectedIndex,blockUpdate)


    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    DAStudio.CustomWebBlocks.notifyBlock(blockHandle,'SelectedStateIndex',num2str(selectedIndex));
    if blockUpdate
        widgetId=get_param(blockHandle,'WebBlockId');
        customwebblocks.utils.stateSelectionChanged(widgetId,selectedIndex);
    end
end

