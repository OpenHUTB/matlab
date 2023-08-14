function ddConn=openOrCreateSimulinkDataDictionary(dictionaryName)



    if(ischar(dictionaryName))
        dictionaryName=string(dictionaryName);
    end
    if(~endsWith(dictionaryName,".sldd"))
        dictionaryName=dictionaryName+".sldd";
    end

    try
        ddConn=systemcomposer.internal.openSimulinkDataDictionary(dictionaryName);
    catch ex
        if strcmp(ex.identifier,'SLDD:sldd:DictionaryNotFound')
            ddConn=Simulink.data.dictionary.create(dictionaryName);
        else
            throw(ex)
        end
    end

end
