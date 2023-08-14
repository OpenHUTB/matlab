function updateFormat(dlg,format)




    dlg.setWidgetValue('format',format);
    dlg.clearWidgetDirtyFlag('format');
    dlg.enableApplyButton(false,false);
end