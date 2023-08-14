function scaleDirectionCallback(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    scaleDirection=dlg.getComboBoxText('scaleDirection');
    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'ScaleDirection',scaleDirection,'undoable');
end

