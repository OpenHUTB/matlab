function utilClearSdi(mdladvObj)

    sdiEngine=mdladvObj.UserData.Progress.sdiEngine;
    runIDs=mdladvObj.UserData.Progress.sdiRunIDs;

    for idx=1:length(runIDs)
        if sdiEngine.isValidRunID(runIDs(idx))


            SDICompRunID=sdiEngine.getAllRunIDs('SDIComparison');
            if~isempty(SDICompRunID)

                currSDICompOwnerID=sdiEngine.getBaselineRunID(SDICompRunID);
                if isequal(currSDICompOwnerID(1),runIDs(idx))
                    sdiEngine.deleteAllRuns('SDIComparison');
                end

            end

            sdiEngine.deleteRun(runIDs(idx));
        end
    end
    mdladvObj.UserData.Progress.sdiRunIDs=[];
end
