function[modelrefs,topProtectedModels]=filterAllProtectedSubmodels(allMdlRefs,protectedMdlRefs)















    if isempty(protectedMdlRefs)
        modelrefs=allMdlRefs;
        topProtectedModels={};
        return;
    end

    protectedSubModels={};
    topProtectedModels={};
    for i=1:length(protectedMdlRefs)

        protectedModelFile=Simulink.ModelReference.ProtectedModel.getProtectedModelFileName(protectedMdlRefs{i});
        [isProtected,fullName]=slInternal('getReferencedModelFileInformation',protectedModelFile);
        fileExists=~(isempty(fullName)||~isProtected);


        if fileExists
            whichFile=which(fullName);
            fileExists=~isempty(whichFile);
        end

        if~fileExists
            protectedSubModels{end+1}=protectedMdlRefs{i};%#ok<AGROW>
        else
            topProtectedModels{end+1}=protectedMdlRefs{i};%#ok<AGROW>
        end
    end

    modelrefs=[allMdlRefs,setdiff(protectedMdlRefs,protectedSubModels)];
end

