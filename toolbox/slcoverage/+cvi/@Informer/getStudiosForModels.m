function studios=getStudiosForModels(modelList)






    studios=[];
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if isempty(allStudios)
        return;
    end


    modelListIdx=~cellfun(@isempty,modelList);
    modelList=modelList(modelListIdx);
    if isempty(modelList)
        return;
    end


    modelListH=get_param(modelList,'handle');
    modelListH=[modelListH{:}];

    matchingStudiosIdx=zeros(size(allStudios),'logical');
    for sIdx=1:length(allStudios)
        curStudio=allStudios(sIdx);
        editors=curStudio.App.getAllEditors;
        editorHandles=[editors.blockDiagramHandle];

        if any(ismember(editorHandles,modelListH))
            matchingStudiosIdx(sIdx)=true;
        end
    end
    studios=allStudios(matchingStudiosIdx);
end
