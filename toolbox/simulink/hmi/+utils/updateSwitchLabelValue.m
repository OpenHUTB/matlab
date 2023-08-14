function updateSwitchLabelValue(dlg,properties)




    dlg.setWidgetValue('offLabel',properties{1});
    dlg.clearWidgetDirtyFlag('offLabel');
    dlg.setWidgetValue('offValue',properties{2});
    dlg.clearWidgetDirtyFlag('offValue');
    dlg.setWidgetValue('onLabel',properties{3});
    dlg.clearWidgetDirtyFlag('onLabel');
    dlg.setWidgetValue('onValue',properties{4});
    dlg.clearWidgetDirtyFlag('onValue');
    dlg.enableApplyButton(false,false);
end