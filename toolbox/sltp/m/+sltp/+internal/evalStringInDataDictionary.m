function tempResult=evalStringInDataDictionary(mdl,str)
    dataDictionaryName=get_param(mdl,'DataDictionary');
    dataDictionary=Simulink.data.dictionary.open(dataDictionaryName);
    designData=getSection(dataDictionary,'Design Data');
    tempResult=evalin(designData,str);
end