function schema=menuMachineDisplayBase(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayBaseValues'));
    schema.tag='ee:MachineDisplayBase';
    schema.state='Hidden';
    schema.callback=@lMachineDisplayBase;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentAsynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSimplifiedSynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSynchronousMachineModel2p1(componentPath)
        schema.state='Enable';
    end
end

function lMachineDisplayBase(callbackInfo)
    baseValues=ee.internal.mask.getPerUnitMachineBase(callbackInfo.getSelection.Handle);
    ee.internal.mask.displayPerUnitMachineBase(callbackInfo.getSelection.Handle,baseValues.b);
end

