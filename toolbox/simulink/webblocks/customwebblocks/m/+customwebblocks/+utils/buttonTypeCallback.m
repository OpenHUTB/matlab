function buttonTypeCallback(dialog,obj)
    blockHandle=get(obj.blockObj,'handle');
    newButtonTypeIndex=dialog.getWidgetValue('buttonType');
    newButtonType='';
    switch newButtonTypeIndex
    case 0
        newButtonType='momentary';
    case 1
        newButtonType='latch';
    end
    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ButtonType',newButtonType,'undoable');
    dialog.clearWidgetDirtyFlag('buttonType');
end

