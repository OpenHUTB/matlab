function dictObj=open(dictFileName)







    dictFilePath=Simulink.interface.dictionary.internal.Utils.getResolvedFilePath(dictFileName);
    if~sl.interface.dict.api.isInterfaceDictionary(dictFilePath)
        DAStudio.error('interface_dictionary:api:InvalidInterfaceDictionary',...
        dictFilePath);
    end

    dictObj=Simulink.interface.dictionary.internal.DictionaryRegistry.getOrOpenInterfaceDictionary(...
    dictFilePath);
end


