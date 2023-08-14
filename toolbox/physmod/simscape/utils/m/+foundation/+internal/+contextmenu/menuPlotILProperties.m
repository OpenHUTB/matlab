function schema=menuPlotILProperties(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:PlotILProperties'));
    schema.tag='simscape:PlotILProperties';
    schema.state='Hidden';
    schema.callback=@lPlotILProperties;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlotILPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotILProperties(cbInfo)
    foundation.internal.mask.plotILProperties(cbInfo.getSelection.Handle)
end
