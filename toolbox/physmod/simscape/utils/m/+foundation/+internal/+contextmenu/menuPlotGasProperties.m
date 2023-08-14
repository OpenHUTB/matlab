function schema=menuPlotGasProperties(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:PlotGasProperties'));
    schema.tag='simscape:PlotGasProperties';
    schema.state='Hidden';
    schema.callback=@lPlotGasProperties;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlotGasPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotGasProperties(cbInfo)
    foundation.internal.mask.plotGasProperties(cbInfo.getSelection.Handle)
end
