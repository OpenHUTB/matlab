function schema=menuSynchronousMachinePlotSaturationPu(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotOpenCircuitSaturation_pu'));
    schema.tag='ee:SynchronousMachinePlotSaturationPu';
    schema.state='Hidden';
    schema.callback=@lSynchronousMachinePlotSaturationPu;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentSynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lSynchronousMachinePlotSaturationPu(callbackInfo)
    isPu=true;
    ee.internal.mask.plotSynchronousMachineSaturation(callbackInfo.getSelection.Handle,...
    isPu);
end

