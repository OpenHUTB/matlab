function schema=menuSynchronousMachineDisplayAssociatedBaseValues(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayAssociatedBaseValues'));
    schema.tag='ee:SynchronousMachineDisplayAssociatedBaseValues';
    schema.state='Hidden';
    schema.callback=@lSynchronousMachineDisplayAssociatedBaseValues;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentSynchronousMachine(componentPath)||...
        ee.internal.mask.isComponentSynchronousMachineModel2p1(componentPath)
        schema.state='Enable';
    end
end

function lSynchronousMachineDisplayAssociatedBaseValues(callbackInfo)
    baseValues=ee.internal.mask.getSynchronousMachineAssociatedBases(callbackInfo.getSelection.Handle);
    ee.internal.mask.displaySynchronousMachineAssociatedBases(callbackInfo.getSelection.Handle,baseValues);
end

