function schema=menuPlotFanCharacteristics(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Fan Characteristics';
    schema.tag='fluids:PlotFanCharacteristics';
    schema.state='Hidden';
    schema.callback=@lPlotFanCharacteristics;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlotFanCharacteristicsSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotFanCharacteristics(cbInfo)
    fluids.internal.mask.plotFanCharacteristics(cbInfo.getSelection.Handle)
end