function mdls=getMdlsToBeClosed(topmdlH)





    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    currStudio=[];
    for j=1:numel(studios)
        if topmdlH==studios(j).App.blockDiagramHandle
            currStudio=studios(j);
            break;
        end
    end
    mdls=topmdlH;
    if isempty(currStudio)
        return;
    else
        mdls=currStudio.App.getBlockDiagramHandles;
        for j=1:numel(studios)
            if currStudio~=studios(j)
                otherHdls=studios(j).App.getBlockDiagramHandles;
                mdls=setdiff(mdls,otherHdls);
            end
        end
    end
end

