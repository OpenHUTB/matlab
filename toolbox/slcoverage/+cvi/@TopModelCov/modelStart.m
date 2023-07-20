function modelStart(modelH,isAccelMdlRef)





    try
        if(nargin<2)
            isAccelMdlRef=false;
        end

        modelcovId=get_param(modelH,'CoverageId');
        if(modelcovId==0)
            return
        end


        cvi.CascMCDC.hideCascMCDCConditions(modelcovId);



        cvi.TopModelCov.updateModelinfo([],modelH);
        performSFChartFixes(modelH);

        testId=cv('get',modelcovId,'.activeTest');

        checkVariants(modelcovId,testId);



        cv('RootUpdateChecksum',cv('get',modelcovId,'.activeRoot'));
        incompatRoot=cv('compareCheckSum',modelcovId);
        if strcmpi(cv('Feature','ModelCov Compatibility'),'on')
            if incompatRoot~=0
                modelcovId=cloneModelcovForNewRoot(modelH,modelcovId,incompatRoot);
            end
        end

        coveng=cvi.TopModelCov.getInstance(modelH);

        if strcmpi(cv('Feature','simscapeCoverage'),'on')
            coveng.simscapeCov=cvi.SimscapeCov;
            coveng.simscapeCov.start();
        end

        setFilterBeforeSim(coveng,modelcovId,testId);

        cvi.TopModelCov.setTestObjective(modelcovId,testId);
        cv('allocateModelCoverageData',modelcovId);
        cv('recordSigrangeAtStart');
        storeVariantsInTestData(testId);
        cvi.TopModelCov.storeSFVariantFilterRules(modelcovId,testId);




        cvi.TopModelCov.storeStartupVariantFilterRules(modelH,testId);



        if(testId~=0&&...
            ~cvprivate('cv_autoscale_settings','isForce',modelH)&&...
            ~SlCov.CoverageAPI.isCovToolUsedBySlicer(modelH)&&...
            ~cv('Private','runningSLDVResultsValidator')&&...
            ~isAccelMdlRef)
            coveng.getReducedBlocks(modelH,testId);
        end
        coveng.setLastReporting(modelH);
    catch MEx
        rethrow(MEx);
    end

    function newModelcovId=cloneModelcovForNewRoot(modelH,modelcovId,rootId)



        modelNameMangled=SlCov.CoverageAPI.getModelcovMangledName(modelcovId);
        matchingModelIds=SlCov.CoverageAPI.findModelcovMangled(modelNameMangled);
        matchingModelIds=matchingModelIds(matchingModelIds~=modelcovId);


        newModelcovId=[];
        for idx=1:numel(matchingModelIds)
            if SlCov.CoverageAPI.isCompatible(modelcovId,matchingModelIds(idx))
                newModelcovId=matchingModelIds(idx);
                break;
            end
        end


        if isempty(newModelcovId)
            modelName=get_param(modelH,'Name');
            oldCoveng=cvi.TopModelCov.getInstance(modelH);


            simMode=SlCov.CovMode(cv('get',modelcovId,'.simMode'));
            newModelcovId=SlCov.CoverageAPI.createModelcov(modelName,modelH,simMode);
            set_param(modelH,'CoverageId',newModelcovId);
            [coveng,newModelcovId]=cvi.TopModelCov.setup(modelH);


            if cv('get',modelcovId,'.topModelcovId')==modelcovId
                refModels=cv('get',modelcovId,'.refModelcovIds');
                refModels=refModels(refModels~=modelcovId);
                cv('set',newModelcovId,'.refModelcovIds',[newModelcovId,refModels]);
            else


                cv('set',newModelcovId,'.topModelcovId',cv('get',modelcovId,'.topModelcovId'));
            end


            coveng.covModelRefData=oldCoveng.covModelRefData;
            coveng.resultSettings=oldCoveng.resultSettings;
            coveng.topModelH=oldCoveng.topModelH;
            coveng.multiInstanceNormaModeSf=oldCoveng.multiInstanceNormaModeSf;
            coveng.scriptDataMap=oldCoveng.scriptDataMap;


            coveng.addModelcov(modelH);
        else
            set_param(modelH,'CoverageId',newModelcovId);
        end


        testId=cv('get',modelcovId,'.activeTest');
        cv('set',newModelcovId,'.activeTest',testId);
        cv('set',modelcovId,'.activeTest',[]);
        oldTests=cv('TestsIn',modelcovId);

        cv('set',modelcovId,'.currentTest',oldTests(1));

        cv('set',testId,'.modelcov',newModelcovId);
        topSlsfId=cv('get',rootId,'.topSlsf');
        descendantCvIds=[topSlsfId,cv('DecendentsOf',topSlsfId)];
        cv('set',descendantCvIds,'.modelcov',newModelcovId);
        metricCondEnum=cvi.MetricRegistry.getEnum('condition');
        metricMcdcEnum=cvi.MetricRegistry.getEnum('mcdc');
        for idx=1:numel(descendantCvIds)
            baseObj=cv('MetricGet',descendantCvIds(idx),metricCondEnum,'.baseObjs');
            if~isempty(baseObj)
                cv('set',baseObj,'.modelcov',newModelcovId);
            end
            mcdcentries=cv('MetricGet',descendantCvIds(idx),metricMcdcEnum,'.baseObjs');
            for mcdcId=mcdcentries(:)'
                conditions=cv('get',mcdcId,'.conditions');
                cv('set',conditions,'.modelcov',newModelcovId);
            end
        end

        cv('set',rootId,'.modelcov',newModelcovId);
        cv('set',newModelcovId,'.activeRoot',rootId);
        cv('set',modelcovId,'.activeRoot',0);


        cv('compareCheckSum',newModelcovId);

        cvi.TopModelCov.cloneBlockTypes(newModelcovId,modelcovId);



        function storeVariantsInTestData(testId)
            if testId==0
                return;
            end
            cvd=cvdata(testId);
            cvd.storeRootVariants();


            function checkVariants(modelcovId,testId)
                if strcmpi(cv('Feature','Variants'),'off')
                    return;
                end
                rootId=cv('get',modelcovId,'.activeRoot');
                cvi.RootVariant.checkVariantSubsystems(rootId);
                if testId==0
                    return;
                end
                cvt=cvtest(testId);
                blockPath=cvt.getCutPath();
                rootVariantId=cvi.RootVariant.addRootVariant(rootId,blockPath);
                if~isempty(rootVariantId)
                    cvi.RootVariant.setRootVariantState(rootId,rootVariantId,0);
                end


                function setFilterBeforeSim(coveng,modelcovId,testId)

                    if testId~=0
                        rootId=cv('get',modelcovId,'.activeRoot');

                        cvi.TopModelCov.setUpFiltering(coveng.topModelH,cvdata(testId),rootId);
                    end


                    function topCvId=getTopSlsf(modelH)

                        covId=get_param(modelH,'CoverageId');
                        topCvId=cv('get',cv('get',covId,'.activeRoot'),'.topSlsf');


                        function performSFChartFixes(modelH)


                            topCvId=getTopSlsf(modelH);
                            chartSubsysCvId2ChartCvId=containers.Map('KeyType','double','ValueType','any');
                            chartCvIds=findCharts(topCvId,chartSubsysCvId2ChartCvId);

                            reconnectAtomicSubchartAndSlinSF(chartCvIds,chartSubsysCvId2ChartCvId);
                            cvi.SFReqTable.fixReqTableDescriptors(chartCvIds);



                            function reconnectAtomicSubchartAndSlinSF(chartCvIds,chartSubsysCvId2ChartCvId)

                                if~isempty(chartCvIds)
                                    subsysCvIds=[];
                                    cvStateIds=[];
                                    for j=1:numel(chartCvIds)
                                        [cvStateIds,subsysCvIds]=findStateSubsysPairs(chartCvIds(j),cvStateIds,subsysCvIds);
                                    end


                                    for idx=1:numel(subsysCvIds)
                                        subsysCvId=subsysCvIds(idx);
                                        if chartSubsysCvId2ChartCvId.isKey(subsysCvId)
                                            subsysCvId=chartSubsysCvId2ChartCvId(subsysCvId);
                                        end
                                        psubsysCvId=cv('get',subsysCvId,'.treeNode.parent');

                                        if Sldv.utils.isAtomicSubchartSubsystem(cv('get',psubsysCvId,'.handle'))
                                            cv('OrphanTreeNode',psubsysCvId);
                                        end
                                        cv('BlockAdoptChildren',cvStateIds(idx),subsysCvId);
                                    end
                                end


                                function chartCvIds=findCharts(topCvId,chartSubsysCvId2ChartCvId)
                                    mixedIds=cv('DecendentsOf',topCvId);
                                    allChartCvId=cv('find',mixedIds,'slsfobj.origin',2,'slsfobj.refClass',sf('get','default','chart.isa'));
                                    chartCvIds=[];
                                    for idx=1:numel(allChartCvId)
                                        cvChartId=allChartCvId(idx);
                                        subsysCvId=cv('get',cvChartId,'.treeNode.parent');
                                        if~sfprivate('is_eml_based_chart',cv('get',cvChartId,'.handle'))
                                            chartCvIds(end+1)=cvChartId;
                                            chartSubsysCvId2ChartCvId(subsysCvId)=cvChartId;
                                        end
                                    end



                                    function[cvStateIds,subsysCvIds]=findStateSubsysPairs(chartCvId,cvStateIds,subsysCvIds)
                                        allcvIds=cv('DecendentsOf',chartCvId);
                                        allStateIds=cv('find',allcvIds,'slsfobj.origin',2,'slsfobj.refClass',sf('get','default','state.isa'));
                                        for idx=1:numel(allStateIds)
                                            cvid=allStateIds(idx);
                                            sfStateId=cv('get',cvid,'.handle');
                                            blockH=sf('get',sfStateId,'.simulink.blockHandle');
                                            if ishandle(blockH)
                                                subsysCvId=get_param(blockH,'CoverageId');%#ok<*AGROW>
                                                if subsysCvId<=0
                                                    libBlockPath=getfullname(blockH);
                                                    libChartPath=sf('FullNameOf',cv('get',chartCvId,'.handle'),'/');
                                                    relBlockPath=libBlockPath(end-(numel(libBlockPath)-numel(libChartPath))+1:end);
                                                    instancePath=cv('get',chartCvId,'.origPath');
                                                    instancePath=Simulink.ID.getFullName(instancePath);
                                                    newBlockPath=[instancePath,relBlockPath];
                                                    subsysCvId=get_param(newBlockPath,'CoverageId');
                                                end
                                                if subsysCvId>0
                                                    subsysCvIds(end+1)=subsysCvId;
                                                    cvStateIds(end+1)=cvid;
                                                end
                                            end
                                        end
