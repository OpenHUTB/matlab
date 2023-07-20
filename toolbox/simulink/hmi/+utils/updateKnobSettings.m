

function updateKnobSettings(dlg,props)

    dlg.setWidgetValue('minimumValue',props.ScaleMin);
    dlg.clearWidgetDirtyFlag('minimumValue');
    dlg.clearWidgetWithError('minimumValue');

    dlg.setWidgetValue('maximumValue',props.ScaleMax);
    dlg.clearWidgetDirtyFlag('maximumValue');
    dlg.clearWidgetWithError('maximumValue');

    dlg.setWidgetValue('tickInterval',props.Tick);
    dlg.clearWidgetDirtyFlag('tickInterval');
    dlg.clearWidgetWithError('tickInterval');

    if isfield(props,'ScaleType')
        dlg.setWidgetValue('scaleType',props.ScaleType);
        dlg.clearWidgetDirtyFlag('scaleType');
    end

    dlg.enableApplyButton(false,false);
end