function subModelsSummary=InspectSubModels(aObj)





    refMdls=aObj.getRefMdls();
    numRefMdls=numel(refMdls);
    subModelsSummary=[];
    configs=cell(1,numRefMdls);
    for i=1:numRefMdls
        mdl=refMdls{i};
        configs{i}=aObj.createConfigurationForSubModel(mdl);
    end
    if aObj.getEnableParallel
        parfor i=1:numel(refMdls)
            summary=configs{i}.callInspect();
            subModelsSummary=[subModelsSummary,summary];
        end
    else
        for i=1:numel(refMdls)
            summary=configs{i}.callInspect();
            subModelsSummary=[subModelsSummary,summary];%#ok
        end
    end


    for i=1:numRefMdls
        configs{i}.getDataManager().saveData();
    end
end

