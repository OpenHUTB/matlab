function schema=menuPlot2PPropertiesContours(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot Fluid Properties (Contours)';
    schema.tag='fluids:Plot2PPropertiesContours';
    schema.state='Hidden';
    schema.callback=@lPlot2PPropertiesContours;
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

function lPlot2PPropertiesContours(cbInfo)
    fluids.internal.mask.plot2PProperties('contours',cbInfo.getSelection.Handle)
end
