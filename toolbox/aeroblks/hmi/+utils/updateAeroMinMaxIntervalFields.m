function updateAeroMinMaxIntervalFields(dlg,properties)





    dlg.clearWidgetWithError('minimumValue');
    dlg.clearWidgetWithError('maximumValue');

    dlg.setWidgetValue('minimumValue',properties{1});
    dlg.setWidgetValue('maximumValue',properties{2});

    dlg.clearWidgetDirtyFlag('minimumValue');
    dlg.clearWidgetDirtyFlag('maximumValue');

    dlg.enableApplyButton(false,false);
end
