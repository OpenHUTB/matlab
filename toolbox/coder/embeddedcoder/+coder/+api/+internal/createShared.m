function codeMapping=createShared(source,configSet)





    if ischar(source)||isstring(source)
        source=Simulink.data.dictionary.open(source);
    end
    if isempty(configSet)
        if~coder.internal.CoderDataStaticAPI.migratedToCoderDictionary(source)
            coder.internal.CoderDataStaticAPI.initializeDictionary(source);
        end
    else
        coder.internal.CoderDataStaticAPI.importFromCS(source,configSet);
    end
    ddSource=coder.api.internal.DataDictionarySource(source);
    codeMapping=coder.api.CodeMapping(ddSource);
end
