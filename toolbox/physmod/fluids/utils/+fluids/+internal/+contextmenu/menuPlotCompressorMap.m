function schema=menuPlotCompressorMap(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Compressor Map';
    schema.tag='fluids:PlotCompressorMap';
    schema.state='Hidden';
    schema.callback=@lPlotCompressorMap;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentCompressorMapSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotCompressorMap(cbInfo)
    fluids.internal.mask.plotCompressorMap(cbInfo.getSelection.Handle)
end
