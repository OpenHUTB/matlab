function schema=menuAsynchronousMachinePlotTorqueSpeedSi(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotTorqueSpeed_SI'));
    schema.tag='ee:AsynchronousMachinePlotTorqueSpeedSi';
    schema.state='Hidden';
    schema.callback=@lAsynchronousMachinePlotTorqueSpeedSi;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lAsynchronousMachinePlotTorqueSpeedSi(callbackInfo)
    isPu=false;
    ee.internal.mask.plotAsynchronousMachineTorqueVersusSpeed(callbackInfo.getSelection.Handle,...
    isPu);
end

