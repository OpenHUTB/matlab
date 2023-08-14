function syncProjectChanges(this,projectSubTreeInfo)




...
...
...
...
...
...
...
...
...
...
...
...
...
...

    import experiments.internal.*;
    projectPath=JSProjectService.getCurrentProjectPath();
    if isempty(projectPath)||~isKey(this.mFilePathToId,projectPath)
        this.closeCurrentProject();
        return;
    end

    proj=currentProject;



    filesInProject=[proj.RootFolder,proj.Files.Path];

    subTreeIdsToRemove={};
    subTreeIdsForUpdate=[];
    subTreeObjsToAdd=[];
    dirNodesToExplore=[];


    for idx=1:length(projectSubTreeInfo)
        nodeInfo=projectSubTreeInfo(idx);
        f=string(nodeInfo.path);
        nodeId=nodeInfo.id;
        if~(exist(f,'file')&&ismember(f,filesInProject))
            path=char(f);
            if isKey(this.mFilePathToId,path)
                this.removeFromIdMaps(path);
            end





            if isKey(this.mFilePathToId,fileparts(path))
                subTreeIdsToRemove{end+1}=nodeId;%#ok<AGROW>
            end
        else
            if nodeInfo.isDirectory&&nodeInfo.shouldExplore
                dirNodesToExplore=addToStructArray(dirNodesToExplore,nodeInfo);
            end
            currentPathStatus=this.currentProject.isInProjectPath(f);
            if currentPathStatus~=nodeInfo.inProjectPath
                subTreeIdsForUpdate=addToStructArray(subTreeIdsForUpdate,...
                struct('id',nodeId,...
                'fieldsToMerge',struct('inProjectPath',currentPathStatus)));
            end
        end
    end



    if~isempty(subTreeIdsToRemove)
        this.emit('removeFromProjectTree',subTreeIdsToRemove);
    end
    if~isempty(subTreeIdsForUpdate)
        this.emit('updateProjectTreeNode',subTreeIdsForUpdate);
    end


    for idx=1:length(dirNodesToExplore)
        path=dirNodesToExplore(idx).path;
        dirInfo=dir(path);
        for jdx=3:length(dirInfo)
            d=dirInfo(jdx);
            filePath=fullfile(d.folder,d.name);
            if~isKey(this.mFilePathToId,filePath)&&~isempty(proj.findFile(filePath))
                if this.isValidExperimentFile(filePath)
                    fixSavedExperimentIfNecessary(filePath)
                end

                treeInfo=this.getSubTreeInfo(this.currentProject,filePath);
                subTreeObjsToAdd=addToStructArray(subTreeObjsToAdd,treeInfo);
            end
        end
    end

    if~isempty(subTreeObjsToAdd)
        this.emit('addToProjectTree',subTreeObjsToAdd);
    end

    function structArray=addToStructArray(structArray,s)
        if isempty(structArray)
            structArray=s;
        else
            structArray(end+1)=s;
        end
    end

    function fixSavedExperimentIfNecessary(filePath)









        storedId=this.getExperimentFileId(filePath);
        if isKey(this.mIdToFilePath,storedId)
            existingFilePathForId=this.mIdToFilePath(storedId);

            if isfile(existingFilePathForId)
                if~strcmp(existingFilePathForId,filePath)
                    Experiment=matfile(filePath).Experiment;
                    [~,Experiment.Name]=fileparts(filePath);
                    Experiment=JSProjectService.updateExpDefForClone(Experiment);
                    save(filePath,'Experiment');
                end
            else


                this.removeFromIdMaps(existingFilePathForId);
            end
        end
    end
end
