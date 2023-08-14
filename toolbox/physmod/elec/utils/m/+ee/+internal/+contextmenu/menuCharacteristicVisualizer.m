function schema=menuCharacteristicVisualizer(callbackInfo)




    schema=sl_action_schema;
    schema.label=getString(message('physmod:ee:library:comments:utils:contextmenu:label_ExploreCharacteristics'));
    schema.tag='ee:CharacteristicVisualizer';
    schema.state='Hidden';
    schema.callback=@lCharacteristicVisualizer;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if ee.internal.mask.isComponentCharacteristicViewerSupported(componentPath)
        schema.state='Enable';
    end
end

function lCharacteristicVisualizer(callbackInfo)
    ee.internal.mask.characteristicVisualizer(callbackInfo.getSelection.Handle);
end
