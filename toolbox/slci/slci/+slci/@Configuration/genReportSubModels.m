function subModelsSummary=genReportSubModels(aObj)





    refMdls=aObj.getRefMdls();
    numRefMdls=numel(refMdls);
    subModelsSummary=[];
    configs=cell(1,numRefMdls);
    for i=1:numRefMdls
        mdl=refMdls{i};
        configs{i}=aObj.createConfigurationForSubModel(mdl);

        configs{i}.setGenVerification(aObj.getGenVerification());
        configs{i}.setGenTraceability(aObj.getGenTraceability());
    end
    if aObj.getEnableParallel
        parfor i=1:numel(refMdls)
            summary=configs{i}.genReport();
            subModelsSummary=[subModelsSummary,summary];
        end
    else
        for i=1:numel(refMdls)
            summary=configs{i}.genReport();
            subModelsSummary=[subModelsSummary,summary];%#ok
        end
    end


    for i=1:numRefMdls
        configs{i}.getDataManager().discardData();
    end
end

