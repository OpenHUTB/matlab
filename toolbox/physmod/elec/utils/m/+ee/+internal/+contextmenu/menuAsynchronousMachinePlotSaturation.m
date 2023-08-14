function schema=menuAsynchronousMachinePlotSaturation(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotOpenCircuitSaturation'));
    schema.tag='ee:AsynchronousMachinePlotSaturation';
    schema.state='Hidden';
    schema.callback=@lAsynchronousMachinePlotSaturation;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lAsynchronousMachinePlotSaturation(callbackInfo)
    ee.internal.mask.plotAsynchronousMachineSaturation(callbackInfo.getSelection.Handle);
end

