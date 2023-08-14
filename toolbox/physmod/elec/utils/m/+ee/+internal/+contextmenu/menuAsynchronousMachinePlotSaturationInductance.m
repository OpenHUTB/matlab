function schema=menuAsynchronousMachinePlotSaturationInductance(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotSaturatedInductance'));
    schema.tag='ee:AsynchronousMachinePlotSaturationInductance';
    schema.state='Hidden';
    schema.callback=@lAsynchronousMachinePlotSaturationInductance;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lAsynchronousMachinePlotSaturationInductance(callbackInfo)
    ee.internal.mask.plotAsynchronousMachineSaturationInductance(callbackInfo.getSelection.Handle);
end

