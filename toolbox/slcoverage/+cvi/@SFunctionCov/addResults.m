function addResults(coveng,modelCovId)







    cvt=cvi.SLCustomCodeCov.getCvTest(coveng,modelCovId);
    if isempty(cvt)
        return
    end

    settings=cvt.settings;
    hasDec=settings.decision;
    hasCond=settings.condition;
    hasMcdc=settings.mcdc;
    hasRelationalBoundary=settings.relationalop;
    mcdcMode=SlCov.getMcdcMode(coveng.topModelH);

    metricNames={'Decision','Condition','MCDC','RelationalBoundary','Statement','FunEntry','FunExit','FunCall'};
    idx=true(size(metricNames));
    idx(1)=hasDec;
    idx(2)=hasCond;
    idx(3)=hasMcdc;
    idx(4)=hasRelationalBoundary;
    metricNames(~idx)=[];


    allmetrics=cvi.MetricRegistry.getDDEnumVals();
    if hasRelationalBoundary
        relOpMetricId=cvi.MetricRegistry.getEnum('cvmetric_Structural_relationalop');
    end


    sfcnCovObj=coveng.slccCov.sfcnCov;
    sfcnName2Info=sfcnCovObj.sfcnName2Info;
    mdlRefNameMap=coveng.slccCov.modelRefNameMap;
    sfcnBlkH2CovId=sfcnCovObj.sfcnBlkH2CovId;



    modelName=SlCov.CoverageAPI.getModelcovName(modelCovId);
    filteredSFcns=sfcnCovObj.filteredSFcnSet.keys();
    filteredSFcns=filteredSFcns(strncmpi([modelName,':'],filteredSFcns,numel(modelName)+1));


    sfcnResults=SlCov.results.CodeCovDataGroup();
    sfcnResults.FilteredInstances=filteredSFcns;

    sfcnNames=sfcnName2Info.keys();

    for ii=1:numel(sfcnNames)

        sfcnInfo=sfcnName2Info(sfcnNames{ii});



        if isempty(sfcnInfo.dbFile)
            continue
        end


        if isempty(sfcnInfo.instances)
            continue
        end


        [instancePaths,ia]=uniquify_instances(mdlRefNameMap,{sfcnInfo.instances.name});

        instanceSIDs=cellfun(@Simulink.ID.getSID,instancePaths,'UniformOutput',false);
        dbResFiles={sfcnInfo.instances(ia).dbFile};

        numInstances=numel(instanceSIDs);
        idx=zeros(1,numInstances);
        for mm=1:numInstances
            mdlName=strtok(instanceSIDs{mm},':');
            if~strcmp(mdlName,modelName)
                continue
            end
            idx(mm)=mm;
        end


        idx(idx==0)=[];
        if isempty(idx)
            continue
        end
        instancePaths=instancePaths(idx);
        instanceSIDs=instanceSIDs(idx);
        dbResFiles=dbResFiles(idx);


        goodCovIds=zeros(1,numel(instancePaths));
        for jj=1:numel(instancePaths)
            sfcnBlkH=get_param(instancePaths{jj},'Handle');
            if sfcnBlkH2CovId.isKey(sfcnBlkH)


                covId=get_param(instancePaths{jj},'CoverageId');
                goodCovIds(jj)=covId;
                if covId>0&&cv('get',covId,'.isDisabled')
                    internal.cxxfe.instrum.runtime.ResultHitsManager.deleteResults(dbResFiles{jj},1);
                end
            end
        end


        traceabilityData=codeinstrum.internal.TraceabilityData(sfcnInfo.dbFile,sfcnInfo.name);
        traceabilityData.close();
        codeCovDataArgs={...
        'traceabilityData',traceabilityData,...
        'instances',struct('name',instancePaths,'SID',instanceSIDs,'resHitsFile',dbResFiles),...
        'metricNames',metricNames,...
        'mcdcMode',mcdcMode...
        };

        sfcnCovObj=SlCov.results.CodeCovData(codeCovDataArgs{:},'name',sfcnInfo.name);
        sfcnCovObj.Mode=SlCov.CovMode.SFunction;
        sfcnResults.add(sfcnCovObj);


        codeCovDataObj=sfcnCovObj.CodeCovDataImpl;
        for jj=1:numel(goodCovIds)
            if goodCovIds(jj)>0


                covId=goodCovIds(jj);


                if hasDec
                    cv('setSFunctionMetricHit',covId,allmetrics.MTRC_DECISION,{codeCovDataObj,jj});
                end
                if hasCond
                    cv('setSFunctionMetricHit',covId,allmetrics.MTRC_CONDITION,{codeCovDataObj,jj});
                end
                if hasMcdc
                    cv('setSFunctionMetricHit',covId,allmetrics.MTRC_MCDC,{codeCovDataObj,jj});
                end
                cv('setSFunctionMetricHit',covId,allmetrics.MTRC_CYCLCOMPLEX,{codeCovDataObj,jj});
                if hasRelationalBoundary
                    cv('setSFunctionMetricHit',covId,relOpMetricId,{codeCovDataObj,jj});
                end

                rationale=cvi.ReportUtils.getFilterRationale(covId);
                if cv('get',covId,'.isDisabled')
                    sfcnCovObj.annotateAllFiles(true,rationale,jj);
                elseif cv('get',covId,'.isJustified')
                    sfcnCovObj.annotateAllFiles(false,rationale,jj);
                end
            end
        end
    end


    if hasResults(sfcnResults)
        covdata=cvdata(cvt.id);
        covdata.sfcnCovData=sfcnResults;
    end


    function[instances,ia,ic]=uniquify_instances(mdlRefNameMap,instances)



        for mm=1:numel(instances)
            [rootName,ipath]=strtok(instances{mm},'/');
            if mdlRefNameMap.isKey(rootName)
                instances{mm}=[mdlRefNameMap(rootName),ipath];
            end
        end

        [instances,ia,ic]=unique(instances,'stable');
