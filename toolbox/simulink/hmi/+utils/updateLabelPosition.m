function updateLabelPosition(dlg,labelPosition)




    dlg.setWidgetValue('labelPosition',labelPosition);
    dlg.clearWidgetDirtyFlag('labelPosition');
    dlg.enableApplyButton(false,false);
end