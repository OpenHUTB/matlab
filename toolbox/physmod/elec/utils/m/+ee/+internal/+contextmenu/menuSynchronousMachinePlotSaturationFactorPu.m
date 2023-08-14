function schema=menuSynchronousMachinePlotSaturationFactorPu(callbackInfo)



    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_PlotSaturationFactor_pu'));
    schema.tag='ee:SynchronousMachinePlotSaturationFactorPu';
    schema.state='Hidden';
    schema.callback=@lSynchronousMachinePlotSaturationFactorPu;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentSynchronousMachine(componentPath)
        schema.state='Enable';
    end
end

function lSynchronousMachinePlotSaturationFactorPu(callbackInfo)
    isPu=true;
    ee.internal.mask.plotSynchronousMachineSaturationFactor(callbackInfo.getSelection.Handle,...
    isPu);
end

