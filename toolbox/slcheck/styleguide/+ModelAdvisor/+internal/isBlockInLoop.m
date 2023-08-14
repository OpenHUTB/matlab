function status=isBlockInLoop(blockHandle,system)




    useHomegrownUtility=false;
    try



        if~strcmp(get_param(bdroot(system),'open'),'on')
            useHomegrownUtility=true;
        else
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if isempty(studios)

                useHomegrownUtility=true;
            else
                studio=studios(1);
                studioApp=studio.App;
                activeEditor=studioApp.getActiveEditor;
                bPath=Simulink.BlockPath.fromHierarchyIdAndHandle(...
                activeEditor.getHierarchyId,blockHandle);

                if isempty(bPath)

                    useHomegrownUtility=true;
                else
                    loopInfo=Simulink.Structure.HiliteTool.findLoop(bPath);
                    status=loopInfo.IsInLoop;
                end
            end
        end
    catch
        useHomegrownUtility=true;
    end

    if useHomegrownUtility
        status=Advisor.Utils.Graph.isBlockHandleInFeedbackLoop(...
        blockHandle,system);
    end
end

