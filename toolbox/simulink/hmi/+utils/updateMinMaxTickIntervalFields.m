function updateMinMaxTickIntervalFields(dlg,properties)




    if~isempty(properties{1})
        dlg.setWidgetValue('scaleType',properties{1});
        dlg.clearWidgetDirtyFlag('scaleType');
    end

    dlg.clearWidgetWithError('minimumValue');
    dlg.clearWidgetWithError('maximumValue');
    dlg.clearWidgetWithError('tickInterval');

    dlg.setWidgetValue('minimumValue',properties{2});
    dlg.clearWidgetDirtyFlag('minimumValue');
    dlg.setWidgetValue('maximumValue',properties{3});
    dlg.clearWidgetDirtyFlag('maximumValue');
    dlg.setWidgetValue('tickInterval',properties{4});
    dlg.clearWidgetDirtyFlag('tickInterval');

    dlg.enableApplyButton(false,false);
end