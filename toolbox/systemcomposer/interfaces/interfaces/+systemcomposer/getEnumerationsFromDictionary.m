function enumList=getEnumerationsFromDictionary(ddConn)
    ddDesignData=ddConn.getSection('Design Data');
    enumEntries=ddDesignData.find('-value','-class','Simulink.data.dictionary.EnumTypeDefinition');
    enumList={enumEntries(:).Name};
end
