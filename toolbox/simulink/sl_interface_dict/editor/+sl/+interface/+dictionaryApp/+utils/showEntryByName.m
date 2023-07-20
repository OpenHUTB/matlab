function showEntryByName(entryName,dictionaryFileSpec)





    dictObj=Simulink.interface.dictionary.open(dictionaryFileSpec);
    if ismember(entryName,dictObj.getInterfaceNames())
        itfDictEntry=dictObj.getInterface(entryName);
    else
        assert(ismember(entryName,dictObj.getDataTypeNames()),...
        ['Entry ',entryName,' no found in interface dictionary']);
        itfDictEntry=dictObj.getDataType(entryName);
    end
    itfDictEntry.show();
end
