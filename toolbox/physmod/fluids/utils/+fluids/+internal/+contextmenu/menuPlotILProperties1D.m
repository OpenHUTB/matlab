function schema=menuPlotILProperties1D(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Fluid Properties';
    schema.tag='fluids:PlotILProperties1D';
    schema.state='Hidden';
    schema.callback=@lPlotILProperties1D;
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

function lPlotILProperties1D(cbInfo)
    fluids.internal.mask.plotILProperties1D(cbInfo.getSelection.Handle)
end
