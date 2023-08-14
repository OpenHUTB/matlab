function schema=menuPlotILProperties2D(cbInfo)










    schema=sl_action_schema;
    schema.label='Plot Predefined Fluid Data';
    schema.tag='fluids:PlotILProperties2D';
    schema.state='Hidden';
    schema.callback=@lPlotILProperties2D;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlotILPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotILProperties2D(cbInfo)
    fluids.internal.mask.plotILProperties2D(cbInfo.getSelection.Handle)
end
