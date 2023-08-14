
function[dataDictionaryStates,index]=addDataDictionary(dataDictionary,dataDictionaryStates)
    import stm.internal.Parameters.*;

    found=false;
    len=length(dataDictionaryStates);
    for i=1:len
        dd=dataDictionaryStates(i).DataDictionary;
        if strcmp(dd.filepath,dataDictionary.filepath)

            index=i;
            found=true;
            break;
        end
    end

    if~found

        ddState=DataDictionaryState(dataDictionary);

        dataDictionaryStates=[dataDictionaryStates,ddState];
        index=length(dataDictionaryStates);
    end
end
