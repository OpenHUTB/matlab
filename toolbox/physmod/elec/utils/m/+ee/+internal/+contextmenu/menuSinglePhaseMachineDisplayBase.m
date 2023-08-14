function schema=menuSinglePhaseMachineDisplayBase(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayBaseValues'));
    schema.tag='ee:SinglePhaseMachineDisplayBase';
    schema.state='Hidden';
    schema.callback=@lSinglePhaseMachineDisplayBase;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentSinglePhaseAsynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lSinglePhaseMachineDisplayBase(callbackInfo)
    baseValues=ee.internal.mask.getPerUnitSinglePhaseMachineBase(callbackInfo.getSelection.Handle);
    ee.internal.mask.displayPerUnitMachineBase(callbackInfo.getSelection.Handle,baseValues.b);
end

