function updateOpacity(dlg,opacity)




    dlg.setWidgetValue('opacity',opacity);
    dlg.clearWidgetDirtyFlag('opacity');
    dlg.clearWidgetWithError('opacity');
    dlg.enableApplyButton(false,false);
end