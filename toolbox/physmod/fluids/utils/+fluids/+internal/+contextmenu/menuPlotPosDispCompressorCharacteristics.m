function schema=menuPlotPosDispCompressorCharacteristics(cbInfo)





    schema=sl_action_schema;
    schema.label='Plot Volumetric Efficiency';
    schema.tag='fluids:PlotPosDispCompressorCharacteristics';
    schema.state='Hidden';
    schema.callback=@lPlotPosDispCompressorCharacteristics;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPosDispCompressorCharacteristicsSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotPosDispCompressorCharacteristics(cbInfo)
    fluids.internal.mask.plotPosDispCompressorCharacteristics(cbInfo.getSelection.Handle)
end
