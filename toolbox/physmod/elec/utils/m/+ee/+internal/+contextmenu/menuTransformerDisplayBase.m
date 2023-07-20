function schema=menuTransformerDisplayBase(callbackInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_DisplayBaseValues'));
    schema.tag='ee:TransformerDisplayBase';
    schema.state='Hidden';
    schema.callback=@lTransformerDisplayBase;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentTransformer(componentPath)
        schema.state='Enable';
    end
end

function lTransformerDisplayBase(callbackInfo)
    baseValues=ee.internal.mask.getPerUnitTransformerBase(callbackInfo.getSelection.Handle);
    ee.internal.mask.displayPerUnitTransformerBase(callbackInfo.getSelection.Handle,baseValues.b);
end
