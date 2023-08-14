function schema=menuPlotLookupTable2D(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:PlotTable'));
    schema.tag='simscape:PlotLookupTable2D';
    schema.state='Hidden';
    schema.callback=@lPlotLookupTable2D;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlotLookupTable2DSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotLookupTable2D(cbInfo)
    foundation.internal.mask.plotLookupTable2D(cbInfo.getSelection.Handle)
end
