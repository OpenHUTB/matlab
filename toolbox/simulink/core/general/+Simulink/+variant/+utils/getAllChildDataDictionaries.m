function childDataDictionaries=getAllChildDataDictionaries(dataDictionaryName,varargin)







    if isempty(varargin)
        dataDictionariesSoFar={dataDictionaryName};
    else
        dataDictionariesSoFar=varargin{1};
    end


    dataDictionaryObj=Simulink.data.dictionary.open(dataDictionaryName);
    childDataDictionaries=dataDictionaryObj.DataSources();


    nestedChildDataDictionaries={};
    for idx=1:numel(childDataDictionaries)
        childDataDictionary=childDataDictionaries{idx};
        if~any(strcmp(dataDictionariesSoFar,childDataDictionary))
            nestedChildDataDictionaries=[nestedChildDataDictionaries;Simulink.variant.utils.getAllChildDataDictionaries(childDataDictionary,[dataDictionariesSoFar,childDataDictionary])];%#ok<AGROW>
        end
    end
    childDataDictionaries=unique([childDataDictionaries;nestedChildDataDictionaries]);
    dataDictionaryObj.close();
end
