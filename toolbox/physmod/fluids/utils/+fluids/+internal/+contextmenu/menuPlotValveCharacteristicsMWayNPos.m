function schema=menuPlotValveCharacteristicsMWayNPos(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Valve Characteristics';
    schema.tag='fluids:PlotValveCharacteristicsMWayNPos';
    schema.state='Hidden';
    schema.callback=@lPlotValveCharacteristicsMWayNPos;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentValveCharacteristicsMWayNPosSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotValveCharacteristicsMWayNPos(cbInfo)
    fluids.internal.mask.plotValveCharacteristicsMWayNPos(cbInfo.getSelection.Handle);
end
