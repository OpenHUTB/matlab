
function highlightClone(cloneResults,subsystem)





    Simulink.CloneDetection.internal.util.checkoutLicenseForCloneDetection();

    if isa(cloneResults,'Simulink.CloneDetection.Results')&&isempty(cloneResults.Clones)
        DAStudio.error('sl_pir_cpp:creator:NoClonesToHighLight');
    end

    subsystemPath=split(subsystem,"/");
    modelName=subsystemPath{1};

    clonesSavedData=...
    Simulink.CloneDetection.internal.util.getClonesDataFromSavedResults(cloneResults);

    modelFileSLX='';
    modelFileMDL='';

    if clonesSavedData.isAcrossModel
        folders=clonesSavedData.listOfFolders;
        currentPwd=pwd;

        for folderIndex=1:length(folders)
            currentFolder=folders{folderIndex};
            cd(currentFolder);

            if(clonesSavedData.FindClonesRecursivelyInFolders)
                modelFileSLX=dir(['**/',modelName,'.slx']);
                modelFileMDL=dir(['**/',modelName,'.mdl']);
            else
                modelFileSLX=dir([modelName,'.slx']);
                modelFileMDL=dir([modelName,'.mdl']);
            end
            if~isempty(modelFileSLX)||~isempty(modelFileMDL)
                break;
            end
        end
        cd(currentPwd);
    elseif clonesSavedData.enableClonesAnywhere
        modelName=clonesSavedData.systemFullName;
        modelFileSLX=dir([modelName,'.slx']);
        modelFileMDL=dir([modelName,'.mdl']);


        if isempty(modelFileSLX)&&isempty(modelFileMDL)
            modelFileSLX=dir(which(modelName));
        end
    else
        modelFileSLX=dir([modelName,'.slx']);
        modelFileMDL=dir([modelName,'.mdl']);


        if isempty(modelFileSLX)&&isempty(modelFileMDL)
            modelFileSLX=dir(which(modelName));
        end
    end

    if isempty(modelFileSLX)&&isempty(modelFileMDL)

        DAStudio.error('Simulink:utility:InvalidBlockDiagramName');
    else
        if isempty(modelFileSLX)
            modelFileSLX=modelFileMDL;
        end
        open_system(fullfile(modelFileSLX(1).folder,modelFileSLX(1).name));
        if clonesSavedData.enableClonesAnywhere
            for i=1:length(clonesSavedData.CloneResults.Clones.CloneGroups)
                for j=1:length(clonesSavedData.CloneResults.Clones.CloneGroups(i).CloneList)
                    if(strcmp(subsystem,clonesSavedData.CloneResults.Clones.CloneGroups(i).CloneList{j}.Name))
                        for k=1:length(clonesSavedData.CloneResults.Clones.CloneGroups(i).CloneList{j}.PatternBlocks)
                            hilite_system(clonesSavedData.CloneResults.Clones.CloneGroups(i).CloneList{j}.PatternBlocks{k});
                        end
                    end
                end

            end
        else
            hilite_system(subsystem);
        end
    end
end

