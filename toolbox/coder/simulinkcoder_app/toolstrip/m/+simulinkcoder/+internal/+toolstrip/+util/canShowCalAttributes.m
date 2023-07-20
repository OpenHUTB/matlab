function showCalAttributes=canShowCalAttributes(model)




    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
    showCalAttributes=strcmp(mappingType,'CoderDictionary')||...
    strcmp(mappingType,'SimulinkCoderCTarget');
    context=simulinkcoder.internal.toolstrip.util.getExpectedCoderAppContext(model);

    if showCalAttributes&&~isempty(context)&&strcmp(context.Name,'embeddedCoderApp')
        showCalAttributes=context.ShowCalAttributes;
    end
end
