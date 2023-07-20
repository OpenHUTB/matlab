
function revertDataDictionaries(dataDictionaryStates)
    len=length(dataDictionaryStates);
    for i=1:len
        ddState=dataDictionaryStates(i);
        dataDictionary=ddState.DataDictionary;
        if~ddState.Dirty


            dataDictionary.discardChanges;
        end

        dataDictionary.close;
    end
end
