function schema=menuMotorDrivePlotEfficiencyMap(callbackInfo)





    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotEfficiencyMap'));
    schema.tag='ee:MotorDrivePlotEfficiencyMap';
    schema.state='Hidden';
    schema.callback=@lMotorDrivePlotEfficiencyMap;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentMotorDrive(componentPath)
        schema.state='Enable';
    end
end

function lMotorDrivePlotEfficiencyMap(callbackInfo)
    ee.internal.mask.plotMotorDriveEfficiencyMap(callbackInfo.getSelection.Handle);
end

