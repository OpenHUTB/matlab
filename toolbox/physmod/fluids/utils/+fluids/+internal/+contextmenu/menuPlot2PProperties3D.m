function schema=menuPlot2PProperties3D(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Fluid Properties (3D)';
    schema.tag='fluids:Plot2PProperties3D';
    schema.state='Hidden';
    schema.callback=@lPlot2PProperties3D;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlot2PPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlot2PProperties3D(cbInfo)
    fluids.internal.mask.plot2PProperties('3D',cbInfo.getSelection.Handle)
end
