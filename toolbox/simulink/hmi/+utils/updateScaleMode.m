

function updateScaleMode(dlg,scaleMode)


    dlg.setWidgetValue('scaleMode',scaleMode);
    dlg.clearWidgetDirtyFlag('scaleMode');
    dlg.enableApplyButton(false,false);
end