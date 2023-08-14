function labelPositionCallback(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    labelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));
    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'LabelPosition',num2str(labelPosition),'undoable');
end
