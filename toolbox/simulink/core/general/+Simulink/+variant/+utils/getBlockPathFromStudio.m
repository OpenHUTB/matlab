

function[rootModelName,blockPath]=getBlockPathFromStudio(blockH)



    rootModelName=[];
    blockPath=[];
    blockH=get_param(blockH,'Handle');
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
    if~isempty(studios)
        studio=studios(1);
        studioApp=studio.App;
        activeEditor=studioApp.getActiveEditor;
        blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,blockH);
        rootModelName=studioApp.topLevelDiagram.getName();
    end
    if isempty(studios)||isempty(blockPath.convertToCell())


        rootModelName=bdroot(getfullname(blockH));
        blockPath=Simulink.BlockPath(getfullname(blockH));
    end
end
