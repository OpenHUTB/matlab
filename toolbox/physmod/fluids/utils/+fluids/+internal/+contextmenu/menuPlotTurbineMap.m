function schema=menuPlotTurbineMap(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Turbine Map';
    schema.tag='fluids:PlotTurbineMap';
    schema.state='Hidden';
    schema.callback=@lPlotTurbineMap;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentTurbineMapSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotTurbineMap(cbInfo)
    fluids.internal.mask.plotTurbineMap(cbInfo.getSelection.Handle)
end
