function schema=menuPlotTLProperties(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:PlotFluidProperties'));
    schema.tag='simscape:PlotTLProperties';
    schema.state='Hidden';
    schema.callback=@lPlotTLProperties;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlotTLPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotTLProperties(cbInfo)
    foundation.internal.mask.plotTLProperties(cbInfo.getSelection.Handle)
end
