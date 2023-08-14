function[hookModelNames,hookCovModes]=getHookModelNames...
    (lBuildInfo,isSil,lInTheLoopType)




    if isempty(lBuildInfo)
        hookModelNames={};
        hookCovModes=[];
        return
    end

    subModelNames=i_getSubModelNames(lBuildInfo);

    hookModelNames=[lBuildInfo.ModelName,subModelNames(:)'];

    if isSil
        subCovModes=repmat(SlCov.CovMode.ModelRefSIL,1,length(subModelNames));
        if lInTheLoopType==rtw.pil.InTheLoopType.ModelBlock
            currentCovMode=SlCov.CovMode.ModelRefSIL;
        else
            currentCovMode=SlCov.CovMode.SIL;
        end
    else
        subCovModes=repmat(SlCov.CovMode.ModelRefPIL,1,length(subModelNames));
        if lInTheLoopType==rtw.pil.InTheLoopType.ModelBlock
            currentCovMode=SlCov.CovMode.ModelRefPIL;
        else
            currentCovMode=SlCov.CovMode.PIL;
        end
    end
    hookCovModes=[currentCovMode,subCovModes];




    function modelNames=i_getSubModelNames(buildInfo)

        if isempty(buildInfo)||isempty(buildInfo.ModelRefs)
            modelNames={};
            return
        end


        paths={buildInfo.ModelRefs.Path};
        paths=strrep(paths,'$(START_DIR)',buildInfo.Settings.LocalAnchorDir);

        modelNames=cell(size(paths));
        for i=1:length(modelNames)
            bi=load(fullfile(paths{i},'buildInfo.mat'));
            modelNames{i}=bi.buildInfo.ModelName;
        end
