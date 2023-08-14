

function dataDictionaryFilePathForModel=getDataDictionaryForModel(modelName)



    dataDictionary=get_param(modelName,'DataDictionary');

    if isempty(dataDictionary)
        dataDictionaryFilePathForModel='';
    else


        openDataDictionaryFilePaths=Simulink.data.dictionary.getOpenDictionaryPaths();
        dataDictionaryFilePathForModelList=openDataDictionaryFilePaths(strcmp(cellfun(@(X)(getDDNameFromFilePath(X)),...
        openDataDictionaryFilePaths,'UniformOutput',false),dataDictionary));
        if numel(dataDictionaryFilePathForModelList)>0



            dataDictionaryFilePathForModel=dataDictionaryFilePathForModelList{1};
        else
            dataDictionaryFilePathForModel=which(dataDictionary);
        end
    end
end


function ddNameWithExt=getDDNameFromFilePath(ddFilePath)
    [~,ddName,ddExt]=fileparts(ddFilePath);
    ddNameWithExt=[ddName,ddExt];
end
