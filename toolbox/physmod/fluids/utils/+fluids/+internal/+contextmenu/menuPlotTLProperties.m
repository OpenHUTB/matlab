function schema=menuPlotTLProperties(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Fluid Properties';
    schema.tag='fluids:PlotTLProperties';
    schema.state='Hidden';
    schema.callback=@lPlotTLProperties;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlotTLPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotTLProperties(cbInfo)
    fluids.internal.mask.plotTLProperties(cbInfo.getSelection.Handle)
end
