function lComponentRegistries=getInstrRegistriesForRefModels...
    (modelRefBuildDirs,lCodeInstrInfo,pathToAnchor,refModelsWithProfiling)



    lComponentRegistries={};
    for i=1:length(refModelsWithProfiling)
        ref=refModelsWithProfiling{i};
        lInstrSrcFolder=getInstrSrcFolder(lCodeInstrInfo,ref);
        matchingBuildDirs=...
        regexp(modelRefBuildDirs,['^.*(\/|\\)',ref,'$'],'match','once');
        matchingBuildDirIdx=cellfun(@(x)~isempty(x),matchingBuildDirs);
        assert(sum(matchingBuildDirIdx)==1,'Must be exactly one match');
        buildDir=matchingBuildDirs{matchingBuildDirIdx};
        profilingInfoFile=fullfile...
        (pathToAnchor,buildDir,lInstrSrcFolder,'profiling_info.mat');
        assert(exist(profilingInfoFile,'file')==2,'The profiling_info.mat file must exist');
        fileContent=load(profilingInfoFile);
        componentRegistries=fileContent.componentRegistries;
        lComponentRegistries=[lComponentRegistries,componentRegistries];%#ok
    end

    for i=1:length(modelRefBuildDirs)
        buildDir=modelRefBuildDirs{i};
        profilingInfoFile=fullfile...
        (pathToAnchor,buildDir,'profiling_info.mat');
        if exist(profilingInfoFile,'file')
            fileContent=load(profilingInfoFile);
            componentRegistries=fileContent.componentRegistries;
            lComponentRegistries=[lComponentRegistries,componentRegistries];%#ok
        end
    end
