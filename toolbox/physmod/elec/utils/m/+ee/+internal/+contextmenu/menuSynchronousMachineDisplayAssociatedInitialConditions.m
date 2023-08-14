function schema=menuSynchronousMachineDisplayAssociatedInitialConditions(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayAssociatedInitialConditions'));
    schema.tag='ee:SynchronousMachineDisplayAssociatedInitialConditions';
    schema.state='Hidden';

    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentSynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSimplifiedSynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSynchronousMachineModel2p1(componentPath)
        schema.state='Enable';
    end

    if ee.internal.mask.isComponentSimplifiedSynchronousMachine(componentPath)
        schema.callback=@lSimplifiedSynchronousMachineDisplayAssociatedInitialConditions;
    else
        schema.callback=@lSynchronousMachineDisplayAssociatedInitialConditions;
    end

end

function lSynchronousMachineDisplayAssociatedInitialConditions(callbackInfo)
    ic=ee.internal.mask.getSynchronousMachineInitialConditions(callbackInfo.getSelection.Handle);
    ee.internal.mask.displaySynchronousMachineInitialConditions(callbackInfo.getSelection.Handle,ic);
end

function lSimplifiedSynchronousMachineDisplayAssociatedInitialConditions(callbackInfo)
    ic=ee.internal.mask.getSimplifiedSynchronousMachineInitialConditions(callbackInfo.getSelection.Handle);
    ee.internal.mask.displaySimplifiedSynchronousMachineInitialConditions(callbackInfo.getSelection.Handle,ic);
end

