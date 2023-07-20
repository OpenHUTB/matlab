function schema=menuQuickPlot(callbackInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_BasicCharacteristics'));
    schema.tag='ee:QuickPlot';
    schema.state='Hidden';
    schema.callback=@lQuickPlot;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentQuickPlotSupported(componentPath)
        schema.state='Enable';
    end
end

function lQuickPlot(callbackInfo)
    ee.internal.mask.quickPlot(callbackInfo.getSelection.Handle);
end
