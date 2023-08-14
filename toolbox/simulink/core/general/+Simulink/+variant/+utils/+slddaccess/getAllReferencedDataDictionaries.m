function referencedDataDictionaries=getAllReferencedDataDictionaries(modelName)







    dataDictionary=get_param(modelName,'DataDictionary');

    if isempty(dataDictionary)
        refDDs={};
    else
        refDDs=Simulink.variant.utils.getAllChildDataDictionaries(dataDictionary)';
    end


    libLinkedDDs=slprivate('getAllDictionariesOfLibrary',modelName);

    libLinkedDDRefDDs=cellfun(@(ddName)(Simulink.variant.utils.getAllChildDataDictionaries(ddName)'),libLinkedDDs,'UniformOutput',false);
    libLinkedDDRefDDs=[libLinkedDDRefDDs{:}];

    referencedDataDictionaries=[refDDs,...
    libLinkedDDs,...
    libLinkedDDRefDDs];
end