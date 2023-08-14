function schema=menuPlot2PProperties3D(cbInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:utils:menus:Plot2PProperties3D'));
    schema.tag='simscape:Plot2PProperties3D';
    schema.state='Hidden';
    schema.callback=@lPlot2PProperties3D;
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

function lPlot2PProperties3D(cbInfo)
    foundation.internal.mask.plot2PProperties('3D',cbInfo.getSelection.Handle)
end
