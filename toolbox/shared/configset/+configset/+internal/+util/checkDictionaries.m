function checkDictionaries(model)












    designData=get_param(model,'DataDictionary');
    coderData=get_param(model,'EmbeddedCoderDictionary');
    if~isempty(coderData)&&~isempty(designData)&&...
        ~strcmp(coderData,designData)&&exist(designData,'file')

        dict=getDataDictionaryWithCoderDictionary(designData);
        if~isempty(dict)

            MSLDiagnostic('RTW:configSet:MultipleEmbeddedCoderDictionaries',...
            dict,coderData).reportAsWarning;
        end
    end

    function out=getDataDictionaryWithCoderDictionary(dictionaryName)


        out='';
        if~sl.interface.dict.api.isInterfaceDictionary(dictionaryName)

            dict=coder.Dictionary(dictionaryName);
            if~dict.empty
                out=dictionaryName;
                return
            end
        end

        dd=Simulink.data.dictionary.open(dictionaryName);
        dataSources=dd.DataSources;
        dd.close;
        for k=1:length(dataSources)
            out=getDataDictionaryWithCoderDictionary(dataSources{k});
            if~isempty(out)
                return
            end
        end
