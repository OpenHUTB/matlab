function[topModelName,modelName,ownerModel,errmsg]=loadTopModelAndRefModels(covdata,covMode)



    try

        topModelName='';

        modelName='';
        ownerModel='';
        errmsg='';

        [topModelcovId,topHarnessCovData]=getTopModel(covdata,covMode);
        if~isempty(topHarnessCovData)
            if topHarnessCovData.isExternalMATLABFile
                modelName=checkModelLoaded(topHarnessCovData);
                return;
            end

            [isHarnessData,tTopModelName,~,errmsg,ownerModel]=cvi.ReportUtils.checkHarnessData(topHarnessCovData);
            if~isempty(errmsg)
                return;
            end
            modelName=checkModelLoaded(topHarnessCovData);
            checkModelLoadedForCovdata(covdata,covMode);
            if isHarnessData
                topModelName=tTopModelName;
            else
                topModelName=modelName;
            end
        else
            modelName=checkModelLoadedForCovdata(covdata,covMode);
            topModelH=cvi.ReportUtils.checkModelLoaded(topModelcovId);
            if topModelH~=0
                topModelName=get_param(topModelH,'name');
            end
        end
    catch MEx
        rethrow(MEx);
    end

    function modelName=checkModelLoadedForCovdata(covdata,covMode)

        if isa(covdata,'cv.cvdatagroup')
            allD=covdata.getAll(covMode);
            for idx=1:length(allD)
                cvd=allD{idx};
                modelName=checkModelLoaded(cvd(1));
            end
        else
            modelName=checkModelLoaded(covdata);
        end


        function modelName=checkModelLoaded(cvd)

            [modelCovId,scriptName]=cvi.ReportUtils.getModelCovId(cvd);
            if~isempty(modelCovId)
                [~,modelName]=cvi.ReportUtils.checkModelLoaded(modelCovId,cvd);
                cvi.ReportData.updateDataIdx(cvd);
                cvi.TopModelCov.checkModelConistency(modelCovId);
            else
                modelName=scriptName;
            end


            function res=isOpen(modelName)
                res=true;
                try
                    get_param(modelName,'name');
                catch MEx %#ok<NASGU>
                    res=false;
                end


                function[topModelcovId,topCovData]=getTopModel(covdata,covMode)

                    topModelcovId=[];
                    topCovData=[];

                    if isa(covdata,'cv.cvdatagroup')
                        allD=covdata.getAll(covMode);
                        xilCovData=[];
                        xilOtherCovData=[];
                        for idx=1:numel(allD)
                            cvd=allD{idx};
                            cvd=cvd(1);



                            if isempty(topCovData)&&...
                                ~isempty(cvd.modelinfo.ownerModel)&&...
                                ~(cvd.isSharedUtility||cvd.isCustomCode)
                                if cvd.isExternalMATLABFile||...
                                    (strcmp(cvd.modelinfo.ownerModel,cvd.modelinfo.analyzedModel)||...
                                    ~strcmp(cvd.modelinfo.ownerModel,cvd.modelinfo.ownerBlock))
                                    topCovData=cvd;
                                end
                            end
                            modelcovId=cv('get',cvd.rootId,'.modelcov');

                            if SlCov.CoverageAPI.isGeneratedCode(modelcovId)
                                if cvd.isSharedUtility||cvd.isCustomCode
                                    xilOtherCovData=[xilOtherCovData;cvd];%#ok<AGROW>
                                else
                                    xilCovData=[xilCovData;cvd];%#ok<AGROW>
                                end
                            end
                            topModelcovId=cv('get',modelcovId,'.topModelcovId');
                            if~isempty(topModelcovId)&&topModelcovId~=0&&...
                                cv('ishandle',topModelcovId)&&...
                                ~isempty(topCovData)&&...
                                ~isempty(cvi.ReportUtils.getModelCovId(cvd))

                                break;
                            end
                        end


                        if(isempty(topModelcovId)||topModelcovId==0)
                            if~isempty(xilCovData)
                                topXilCovData=xilCovData(1);
                                for idx=1:numel(xilCovData)

                                    if xilCovData(idx).simMode==SlCov.CovMode.SIL||...
                                        xilCovData(idx).simMode==SlCov.CovMode.PIL
                                        topXilCovData=xilCovData(idx);
                                    end
                                end
                                topModelcovId=cv('get',topXilCovData.rootId,'.modelcov');
                            elseif~isempty(xilOtherCovData)&&numel(xilOtherCovData)==numel(allD)

                                topModelcovId=cv('get',xilOtherCovData(1).rootId,'.modelcov');
                            end
                        end
                    else
                        modelcovId=cv('get',covdata.rootId,'.modelcov');

                        topModelcovId=cv('get',modelcovId,'.topModelcovId');
                        if~isempty(covdata.modelinfo.ownerModel)
                            topCovData=covdata;
                        end

                        if isempty(topModelcovId)...
                            ||topModelcovId==0
                            topModelcovId=modelcovId;
                        end
                    end






