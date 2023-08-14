function schema=menuPlotCentrifugalPumpCharacteristics(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Pump Characteristics';
    schema.tag='fluids:PlotCentrifugalPumpCharacteristics';
    schema.state='Hidden';
    schema.callback=@lPlotCentrifugalPumpCharacteristics;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlotCentrifugalPumpCharacteristicsSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotCentrifugalPumpCharacteristics(cbInfo)
    fluids.internal.mask.plotCentrifugalPumpCharacteristics(cbInfo.getSelection.Handle)
end