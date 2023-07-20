function clones=getCloneDetectionData(componentPath,isFollowModelRef,isFollowLibraryLinks)





    try
        clones=[];
        cloneDetectionSettings=Simulink.CloneDetection.Settings();
        cloneDetectionSettings.ExcludeModelReferences=~isFollowModelRef;
        cloneDetectionSettings.ExcludeLibraryLinks=~isFollowLibraryLinks;
        cloneDetectionSettings.ParamDifferenceThreshold=intmax('uint32');
        cloneDetectionSettings.IgnoreSignalName=true;
        cloneDetectionSettings.IgnoreBlockProperty=true;
        cloneResults=Simulink.CloneDetection.findClones(...
        componentPath,cloneDetectionSettings);
        if~isempty(cloneResults.Clones)
            cloneGroups=cloneResults.Clones.CloneGroups;
            k=1;
            loadedModels=find_system('Type','block_diagram');
            for i=1:numel(cloneGroups)
                cloneList=cloneGroups(i).CloneList;


                keep=false(size(cloneList));
                for j=1:numel(cloneList)
                    clone=cloneList{j};
                    modelClone=strtok(clone,'/');
                    if any(strcmp(modelClone,loadedModels))
                        keep(j)=true;
                    end
                end
                cloneList=cloneList(keep);


                if numel(cloneList)>1
                    for j=1:numel(cloneList)
                        clones{k}{j,1}=Simulink.ID.getSID(cloneList{j});%#ok<AGROW> 
                    end
                    k=k+1;
                end

            end
        end
    catch ME
        rethrow(ME);
    end

end

