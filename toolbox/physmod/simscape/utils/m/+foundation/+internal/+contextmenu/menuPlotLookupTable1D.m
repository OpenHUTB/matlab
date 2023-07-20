function schema=menuPlotLookupTable1D(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:PlotTable'));
    schema.tag='simscape:PlotLookupTable1D';
    schema.state='Hidden';
    schema.callback=@lPlotLookupTable1D;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlotLookupTable1DSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotLookupTable1D(cbInfo)
    foundation.internal.mask.plotLookupTable1D(cbInfo.getSelection.Handle)
end
