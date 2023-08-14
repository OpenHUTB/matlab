function applyCoverageFilter(OrigModelH,SubSystemH,ModelH,extractedModelFullPath,origFilterFileNameCV)





    if nargin<5||isempty(origFilterFileNameCV)
        origFilterFileNameCV=get_param(OrigModelH,'CovFilter');
    end
    if~isempty(origFilterFileNameCV)
        origFilterObj=SlCov.FilterEditor.createFilterEditor(OrigModelH,origFilterFileNameCV);
        newFilterFileName=createCovFilterForExtactedModel(...
        origFilterObj,SubSystemH,ModelH,extractedModelFullPath,'_covfilter');
        set_param(ModelH,'CovFilter',newFilterFileName);
    end

    opts=sldvoptions(OrigModelH);


    objParams=get_param(OrigModelH,'ObjectParameters');
    origFilterFileNameDV='';
    if strcmpi(opts.CovFilter,'on')
        origFilterFileNameDV=opts.CovFilterFileName;
    else
        set_param(ModelH,'CovEnable',get_param(OrigModelH,'CovEnable'));
        set_param(ModelH,'CovIncludeTopModel',get_param(OrigModelH,'CovIncludeTopModel'));
        set_param(ModelH,'CovIncludeRefModels',get_param(OrigModelH,'CovIncludeRefModels'));
        if isfield(objParams,'DVCovFilterFileName')
            origFilterFileNameDV=get_param(OrigModelH,'DVCovFilterFileName');
        end
    end

    if~isempty(origFilterFileNameDV)
        origFilterObjDV=SlCov.FilterEditor.createFilterEditor(OrigModelH,origFilterFileNameDV);
        newFilterFileName=createCovFilterForExtactedModel(...
        origFilterObjDV,SubSystemH,ModelH,extractedModelFullPath,'_dvfilter');
        set_param(ModelH,'DVCovFilterFileName',newFilterFileName)
    end

end

function newFilterFileName=createCovFilterForExtactedModel(origFilterObj,...
    subSystemBlockH,extractModelH,extractedModelFullPath,filtNameSuffix)


    [~,extractModelName,~]=fileparts(extractedModelFullPath);
    [extractDirPath,baseName]=fileparts(extractedModelFullPath);
    newFilterFileName=[baseName,filtNameSuffix];
    newFilterObj=SlCov.FilterEditor.createFilterEditor(extractModelH,[]);

    keys=origFilterObj.filterState.keys;
    for idx=1:length(keys)
        if Simulink.ID.isValid(keys{idx})


            if slfeature('UnifiedHarnessExtract')>0
                newSID=Simulink.harness.internal.sidmap.getExtractedModelObjectSID(keys{idx},subSystemBlockH,extractModelName);
            else
                newSID=Simulink.ID.getSubsystemBuildSID(keys{idx},subSystemBlockH,extractModelName);
            end
            if Simulink.ID.isValid(newSID)
                newFilterObj.setFilter(newSID,origFilterObj.filterState(keys{idx}).Rationale);
            end
        else

            newFilterObj.filterState(keys{idx})=origFilterObj.filterState(keys{idx});
        end
    end

    newFilterObj.save(fullfile(extractDirPath,newFilterFileName));
end

