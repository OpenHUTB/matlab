function updateReferencedModelLinkables(buildInfo,buildInfoPathOrig,...
    modules,instrObjFolderModules)




    buildInfoOriginal=coder.make.internal.loadBuildInfo...
    (buildInfoPathOrig);
    linkablesOriginal=buildInfoOriginal.Linkables;
    modelRefsOriginal=buildInfoOriginal.ModelRefs;

    if isempty(modelRefsOriginal)
        modelRefNames={};
        modelRefLibNames={};
    else
        modelRefNames=cell(size(modelRefsOriginal));
        for i=1:length(modelRefNames)
            modelRefNames{i}=...
            modelRefsOriginal(i).BuildInfoHandle.ComponentName;
        end
        modelRefLibNames={modelRefsOriginal.Name};
    end


    modelRefsDirect=buildInfo.ModelRefsDirect;
    if~isempty(modelRefsDirect)
        removeLinkables(buildInfo,{modelRefsDirect.Name})
    end
    linkablesInstr=buildInfo.Linkables;



    linkablesUpdated=linkablesOriginal;
    anchorFolder=buildInfoOriginal.Settings.LocalAnchorDir;
    for i=1:length(modelRefLibNames)
        modelRefLibName=modelRefLibNames{i};
        moduleIdx=strcmp(modelRefNames{i},modules);
        if~any(moduleIdx)


            continue
        end
        moduleObjFolder=instrObjFolderModules{moduleIdx};
        if~isempty(moduleObjFolder)
            linkableOriginal=modelRefsOriginal(i);
            modelRefPath=...
            linkableOriginal.BuildInfoHandle.ComponentBuildFolder;
            instrPath=fullfile(anchorFolder,modelRefPath,...
            moduleObjFolder);
            instrBuildInfo=coder.make.internal.loadBuildInfo(instrPath);



            removeLinkables(instrBuildInfo);

            linkablesUpdatedIdx=strcmp(modelRefLibName,...
            {linkablesUpdated.Name});
            linkableToUpdate=linkablesUpdated(linkablesUpdatedIdx);
            linkableToUpdate.BuildInfoHandle=instrBuildInfo;
            linkableToUpdate.Path=fullfile(linkableToUpdate.Path,...
            moduleObjFolder);
        end
    end
    buildInfo.removeLinkables;

    nonModelRefLinkableNames={linkablesInstr.Name};
    [~,keepIdx]=intersect({linkablesUpdated.Name},...
    nonModelRefLinkableNames);
    linkablesUpdated(keepIdx)=linkablesInstr;

    buildInfo.setLinkablesDirect(linkablesUpdated);


