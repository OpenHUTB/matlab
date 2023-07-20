function updateAlignment(dlg,alignment)




    dlg.setWidgetValue('alignment',alignment);
    dlg.clearWidgetDirtyFlag('alignment');
    dlg.enableApplyButton(false,false);
end