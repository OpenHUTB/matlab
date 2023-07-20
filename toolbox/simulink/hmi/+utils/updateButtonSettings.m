

function updateButtonSettings(dlg,properties)

    dlg.setWidgetValue('buttonText',properties{1});
    dlg.clearWidgetDirtyFlag('buttonText');
    dlg.setWidgetValue('onValue',properties{2});
    dlg.clearWidgetDirtyFlag('onValue');
    dlg.enableApplyButton(false,false);
end