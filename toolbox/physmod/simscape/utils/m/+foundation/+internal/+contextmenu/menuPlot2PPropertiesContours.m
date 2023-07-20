function schema=menuPlot2PPropertiesContours(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:Plot2PPropertiesContours'));
    schema.tag='simscape:Plot2PPropertiesContours';
    schema.state='Hidden';
    schema.callback=@lPlot2PPropertiesContours;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if foundation.internal.mask.isComponentPlot2PPropertiesSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlot2PPropertiesContours(cbInfo)
    foundation.internal.mask.plot2PProperties('contours',cbInfo.getSelection.Handle)
end
