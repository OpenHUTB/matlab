function[modelObj,diagramFile]=getModelFromProject(specifiedModelName,...
    projectContent,tfUseSingleProject,defaultModelIdx,archiveDir)

    if ismissing(specifiedModelName)

        if tfUseSingleProject

            specifiedModelName=projectContent.ModelNames(defaultModelIdx);
            modelIdx=defaultModelIdx;
        else
            specifiedModelName=projectContent.ModelNames;
            modelIdx=1;
        end
    else
        modelIdx=projectContent.ModelNames==specifiedModelName;
    end

    modelVariableName=projectContent.ModelVariableNames(modelIdx);
    if ismissing(modelVariableName)

        loadStruct=load(fullfile(archiveDir,"simbiodata.mat"));
        allModelVariableNames=fields(loadStruct);
        allModelNames=string(cellfun(@(modelVarName)loadStruct.(modelVarName).Name,...
        allModelVariableNames,"UniformOutput",false));
        [~,modelIdx]=ismember(specifiedModelName,allModelNames);
        modelObj=loadStruct.(allModelVariableNames{modelIdx});
    else

        loadStruct=load(fullfile(archiveDir,"simbiodata.mat"),modelVariableName);
        modelObj=loadStruct.(modelVariableName);
    end

    diagramFile=projectContent.DiagramFiles(modelIdx);

end