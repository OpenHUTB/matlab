function schema=menuPlotValveCharacteristics(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Valve Characteristics';
    schema.tag='fluids:PlotValveCharacteristics';
    schema.state='Hidden';
    schema.callback=@lPlotValveCharacteristics;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentValveCharacteristicsSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotValveCharacteristics(cbInfo)
    fluids.internal.mask.plotValveCharacteristics(cbInfo.getSelection.Handle)
end
