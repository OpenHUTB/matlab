function subModelsSummary=CheckSubModels(aObj)





    subModelsSummary=[];
    refMdls=aObj.getRefMdls();
    for i=1:numel(refMdls)
        mdl=refMdls{i};
        configuration=aObj.createConfigurationForSubModel(mdl);
        summary=configuration.checkModelCompatibility();
        subModelsSummary=[subModelsSummary,summary];%#ok
    end
end

