function res=loadAndApplyFilter(cvd)



    try
        res=false;
        rootId=cvd.rootID;


        fA=cvi.TopModelCov.getFilterApplied(cvd.rootId);
        if isempty(cvd.filterData)&&isempty(cvd.filter)&&...
            isempty(cvd.filterApplied)&&(isempty(fA)||isempty(fA(1).fileNameId))
            return;
        end

        modelcovId=cv('get',rootId,'.modelcov');
        modelH=cvdata.findTopModelHandle(cvd);
        isHarnessData=false;
        if~isValidModelH(modelH)
            if SlCov.CovMode.isGeneratedCode(cvd.simMode)&&(cvd.isSharedUtility||cvd.isCustomCode)


                if~isValidModelH(modelH)


                    try
                        [topModelName,~,ownerModel]=...
                        cvi.ReportUtils.loadTopModelAndRefModels(cvd,cvd.simMode);
                        modelNameToUse='';
                        if~isempty(ownerModel)
                            modelNameToUse=ownerModel;
                        elseif~isempty(topModelName)
                            modelNameToUse=topModelName;
                        elseif cv('ishandle',topModelcovId)
                            modelNameToUse=SlCov.CoverageAPI.getModelcovName(topModelcovId);
                        end
                        if~isempty(modelNameToUse)
                            if~bdIsLoaded(modelNameToUse)
                                load_system(modelNameToUse);
                                clrObj=onCleanup(@()bdclose(modelNameToUse));
                            end
                            modelH=get_param(modelNameToUse,'handle');
                        end
                    catch
                        modelH=0;
                    end
                end
                try
                    [topModelName,~,ownerModel]=...
                    cvi.ReportUtils.loadTopModelAndRefModels(cvd,cvd.simMode);
                    modelNameToUse='';
                    if~isempty(ownerModel)
                        modelNameToUse=ownerModel;
                    elseif~isempty(topModelName)
                        modelNameToUse=topModelName;
                    elseif cv('ishandle',topModelcovId)
                        modelNameToUse=SlCov.CoverageAPI.getModelcovName(topModelcovId);
                    end
                    if~isempty(modelNameToUse)
                        if~bdIsLoaded(modelNameToUse)
                            load_system(modelNameToUse);
                            clrObj=onCleanup(@()bdclose(modelNameToUse));
                        end
                        modelH=get_param(modelNameToUse,'handle');
                    end
                catch
                    modelH=0;
                end
            elseif~cvd.isSimulinkCustomCode


                modelH=cv('get',modelcovId,'.handle');
                if~isValidModelH(modelH)
                    try











                        ownerModel=cv('get',modelcovId,'.ownerModel');
                        if~isempty(ownerModel)&&~contains(ownerModel,'notUnique')
                            if~bdIsLoaded(ownerModel)
                                load_system(ownerModel);
                                clrObj=onCleanup(@()bdclose(ownerModel));
                            end
                            modelH=get_param(ownerModel,'Handle');
                            cvi.ReportUtils.checkHarnessData(cvd);
                            isHarnessData=true;
                        end
                    catch MEx

                        rethrow(MEx);
                    end
                end
            end
            if~isValidModelH(modelH)
                cvd.filterApplied='#notapplied#';
                return;
            end
        end
        if~isHarnessData
            cvi.ReportUtils.checkModelLoaded(modelcovId);
        end
        applyFilter(cvd);
    catch MEx
        rethrow(MEx);
    end
end

function res=isValidModelH(modelH)
    res=~isempty(modelH)&&modelH~=0&&ishandle(modelH);
end
