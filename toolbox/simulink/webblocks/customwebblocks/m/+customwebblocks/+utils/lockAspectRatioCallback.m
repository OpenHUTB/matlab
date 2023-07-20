function lockAspectRatioCallback(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    lockAspectRatio=dlg.getWidgetValue('lockAspectRatio');
    if lockAspectRatio
        lockAspectRatio='on';
    else
        lockAspectRatio='off';
    end
    DAStudio.CustomWebBlocks.notifyWebFrontEnd(blockHandle,'fixedAspectRatio',lockAspectRatio,'undoable');
end

