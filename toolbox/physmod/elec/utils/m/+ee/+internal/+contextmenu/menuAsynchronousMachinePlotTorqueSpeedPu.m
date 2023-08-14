function schema=menuAsynchronousMachinePlotTorqueSpeedPu(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotTorqueSpeed_pu'));
    schema.tag='ee:AsynchronousMachinePlotTorqueSpeedPu';
    schema.state='Hidden';
    schema.callback=@lAsynchronousMachinePlotTorqueSpeedPu;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lAsynchronousMachinePlotTorqueSpeedPu(callbackInfo)
    isPu=true;
    ee.internal.mask.plotAsynchronousMachineTorqueVersusSpeed(callbackInfo.getSelection.Handle,...
    isPu);
end

