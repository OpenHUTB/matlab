function schema=menuAsynchronousMachinePlotSaturationFactor(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotSaturationFactor'));
    schema.tag='ee:AsynchronousMachinePlotSaturationFactor';
    schema.state='Hidden';
    schema.callback=@lAsynchronousMachinePlotSaturationFactor;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lAsynchronousMachinePlotSaturationFactor(callbackInfo)
    ee.internal.mask.plotAsynchronousMachineSaturationFactor(callbackInfo.getSelection.Handle);
end

