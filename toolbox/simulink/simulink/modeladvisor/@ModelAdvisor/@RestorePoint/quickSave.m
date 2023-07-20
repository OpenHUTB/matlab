function quickSave




    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    snapshots=MAObj.getRestorePointList;

    index=1;
    snapname=['autosave',num2str(index)];
    while isDuplicate(snapshots,snapname)
        index=index+1;
        snapname=['autosave',num2str(index)];
    end

    MAObj.saveRestorePoint(snapname,'');

    if isa(MAObj.RPDialog,'DAStudio.Dialog')
        MAObj.RPDialog.restoreFromSchema;
    end


    function found=isDuplicate(snapshots,newname)
        found=false;
        for i=1:length(snapshots)
            if strcmp(snapshots{i}.name,newname)
                found=true;
                break
            end
        end