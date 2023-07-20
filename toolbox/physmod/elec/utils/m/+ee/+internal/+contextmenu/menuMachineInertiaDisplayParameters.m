function schema=menuMachineInertiaDisplayParameters(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayParameters'));
    schema.tag='ee:MachineInertiaDisplayParameters';
    schema.state='Hidden';
    schema.callback=@lMachineInertiaDisplayParameters;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentMachineInertia(componentPath)
        schema.state='Enable';
    end
end

function lMachineInertiaDisplayParameters(callbackInfo)
    parameters=ee.internal.mask.getMachineInertiaParameters(callbackInfo.getSelection.Handle);
    ee.internal.mask.displayMachineInertiaParameters(callbackInfo.getSelection.Handle,parameters);
end

