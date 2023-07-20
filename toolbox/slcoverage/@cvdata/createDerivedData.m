function createDerivedData(this,lhs,rhs,metrics,trace)




    cvdArray=[lhs,rhs];


    defaultValue=cvdArray(1);

    for i=2:length(cvdArray)
        if defaultValue.simMode~=cvdArray(i).simMode
            error(message('Slvnv:simcoverage:cvdata:IncompSimModes',...
            SlCov.CovMode.toString(defaultValue.simMode),SlCov.CovMode.toString(cvdArray(i).simMode)));
        end
    end

    data.type='DERIVED_DATA';
    data.metrics=add_metrics_fields(metrics);
    data.traceOn=any([cvdArray.traceOn]);
    if data.traceOn
        data.trace=trace;
    end
    data.testSettings=merge_testSettings(cvdArray);
    data.filterData=merge_filterData(cvdArray);
    data.excludeInactiveVariants=all([cvdArray.excludeInactiveVariants]);
    data.checksum=calcNewChecksum('checksum',cvdArray);
    data.structuralChecksum=defaultValue.structuralChecksum;
    data.relBndMetricChecksum=calcNewChecksum('relBndMetricChecksum',cvdArray);
    data.satOvfMetricChecksum=calcNewChecksum('satOvfMetricChecksum',cvdArray);
    data.variantChecksum=defaultValue.variantChecksum;
    data.startTimeEnum=earliest_time([cvdArray.startTimeEnum]);
    data.stopTimeEnum=latest_time([cvdArray.stopTimeEnum]);
    data.simulationStartTime=earliest_time([cvdArray.simulationStartTime]);
    data.simulationStopTime=latest_time([cvdArray.simulationStopTime]);


    data.startTime=data.startTimeEnum;
    data.stopTime=data.stopTimeEnum;

    data.intervalStartTime=min([cvdArray.intervalStartTime]);
    data.intervalStopTime=min([cvdArray.intervalStopTime]);

    data.rootId=defaultValue.rootId;
    data.variantStates=defaultValue.getRootVariantStates();
    data.modelinfo=match_modelinfo(cvdArray);


    if SlCov.CovMode.isGeneratedCode(defaultValue.simMode)
        isATS=arrayfun(@(cvd)cvd.isAtomicSubsystemCode(),cvdArray);
        modelInfoArr=[cvdArray.modelinfo];
        modelInfo=data.modelinfo;
        if any(isATS)
            if all(isATS)



                if~isequal(modelInfoArr.ownerBlock)
                    modelInfo.analyzedModel=modelInfoArr(1).ownerModel;
                end
            else


                modelinfoRef=modelInfoArr(find(~isATS,1));
                modelInfo.analyzedModel=modelinfoRef.analyzedModel;
                modelInfo.ownerModel=modelinfoRef.ownerModel;
                modelInfo.ownerBlock=modelinfoRef.ownerBlock;
                modelInfo.harnessModel=modelinfoRef.harnessModel;
            end
        else

            if any(arrayfun(@(info)isempty(info.ownerModel),modelInfoArr))
                modelInfo.ownerModel='';
            end
        end
        data.modelinfo=modelInfo;
    end

    data.sfcnCovData=[];
    data.codeCovData=[];
    data.isObserver=defaultValue.isObserver;
    data.isExternalMATLABFile=defaultValue.isExternalMATLABFile;
    data.isSubsystem=defaultValue.isExternalMATLABFile;
    data.isSimulinkCustomCode=false;
    data.isSharedUtility=false;
    data.isCustomCode=false;
    data.covSFcnEnable=false;
    data.simMode=defaultValue.simMode;
    data.dbVersion=defaultValue.dbVersion;
    data=checkFilter(data,cvdArray);

    data.testRunInfo=[];

    data.reqTestMapInfo=defaultValue.reqTestMapInfo;
    data.scopeDataToReqs=any([cvdArray.scopeDataToReqs]);

    this.localData=data;





    if~isempty(defaultValue.sfcnCovData)&&...
        isa(defaultValue.sfcnCovData,'SlCov.results.CodeCovDataGroup')
        this.localData.sfcnCovData=clone(defaultValue.sfcnCovData);
    end

    if~isempty(defaultValue.codeCovData)&&...
        isa(defaultValue.codeCovData,'SlCov.results.CodeCovData')
        this.localData.codeCovData=clone(defaultValue.codeCovData);
        this.localData.codeCovData.setCovData(this);
    end
    this.localData.isSharedUtility=defaultValue.isSharedUtility;
    this.localData.isCustomCode=defaultValue.isCustomCode;
    this.localData.covSFcnEnable=defaultValue.covSFcnEnable;
    this.localData.isSimulinkCustomCode=defaultValue.isSimulinkCustomCode;

    cv.internal.cvdata.aggregateDescription(this,[],cvdArray);
    this.setUniqueId;

end


function newChecksum=calcNewChecksum(checksumFieldName,cvdArray)
    defaultChecksum=cvdArray(1).(checksumFieldName);

    if all(arrayfun(@(x)isequal(x.(checksumFieldName),defaultChecksum),cvdArray))
        newChecksum=defaultChecksum;
    else
        newChecksum=cvi.TopModelCov.derivedDataIncompatibleChecksum;
    end

end


function testSettings=merge_testSettings(cvdArray)
    testSettings_array=[cvdArray.testSettings];
    allMetrics=fields(testSettings_array);
    testSettings=testSettings_array(1);

    for i=1:length(allMetrics)
        metric=allMetrics{i};
        testSettings.(metric)=any([testSettings_array.(metric)]);
    end
end

function newFilterData=merge_filterData(cvdArr)

    newFilterData=[];
    filterData=[cvdArr.filterData];
    if isempty(filterData)
        return;
    end

    types=unique({filterData.type});
    newFilterData=struct('id','','type',types,'rules','','concatOp','');
    for idx=1:numel(types)
        cFD=filterData({filterData.type}==string(types{idx}));
        if numel(cFD)>1
            newFilterData(idx).id=char(matlab.lang.internal.uuid);
            concatOp=cFD(1).concatOp;
            newFilterData(idx).concatOp=concatOp;
            if concatOp==0
                newFilterData(idx).rules=unique([cFD.rules]);
            elseif concatOp==1
                newRules=cFD(1).rules;
                for r=2:numel(cFD)
                    newRules=intersect(newRules,cFD(r).rules);
                end
                newFilterData(idx).rules=newRules;
            end
        else

            if~isempty(cFD)&&(numel(cvdArr)>1)&&(cFD.concatOp==1)

                cFD.rules={};
            end
            newFilterData(idx)=cFD;
        end
    end
end

function data=checkFilter(data,cvdArray)
    data.covFilter='';
    data.filterApplied='';
    data.covFilter=combine_filter({cvdArray.filter});
    data.filterApplied=combine_filter({cvdArray.filterApplied});
end


function combined=combine_filter(fileNameArr)







    combined=cellfun(@(v)reshape(v,[1,numel(v)]),fileNameArr,'UniformOutput',false);




    emptyIdx=cellfun(@isempty,combined);
    combined(emptyIdx)=[];



    if~iscellstr(combined)
        combined=[combined{:}];
    end






    emptyIdx=cellfun(@isempty,combined);
    combined(emptyIdx)=[];



    if isempty(combined)
        combined='';
    elseif iscell(combined)&&numel(combined)==1
        combined=combined{1};
    else

        combined=unique(combined);
    end
end

function modelinfo=match_modelinfo(cvdArray)
    numCvd=length(cvdArray);


    rawModelInfoArr(numCvd)=cvdArray(numCvd).getRawModelInfo();
    for i=1:numCvd-1
        rawModelInfoArr(i)=cvdArray(i).getRawModelInfo();
    end

    modelinfo=rawModelInfoArr(1);
    fieldNames=fieldnames(modelinfo);
    for fn=fieldNames(:)'
        field=fn{1};

        if~isequal(rawModelInfoArr.(field))%#ok<LTARG>
            switch field
            case 'analyzedModel'
                val=checkAnalyzedModel(rawModelInfoArr);

            case 'reducedBlocks'
                numRedBlks=arrayfun(@(info)numel(info.reducedBlocks),rawModelInfoArr);
                [~,maxIdx]=max(numRedBlks);
                val=rawModelInfoArr(maxIdx).reducedBlocks;

            otherwise
                val='notUnique';
            end
            modelinfo.(field)=val;
        end
    end
end


function metrics=add_metrics_fields(metrics)

    [metricNames,toMetricNames]=cvi.MetricRegistry.getAllMetricNames;

    for i=1:length(metricNames)
        if~isfield(metrics,metricNames{i})
            metrics.(metricNames{i})=[];
        end
    end
    if isfield(metrics,'testobjectives')
        for i=1:length(toMetricNames)
            if~isfield(metrics.testobjectives,toMetricNames{i})
                metrics.testobjectives.(toMetricNames{i})=[];
            end
        end
    else
        metrics.testobjectives=[];
    end

end


function res=earliest_time(allTimes)
    try
        res=min(allTimes);
    catch Mex %#ok<NASGU>
        res=0;
    end
end


function res=latest_time(allTimes)
    try
        res=max(allTimes);
    catch Mex %#ok<NASGU>
        res=0;
    end
end

function analyzedModel=checkAnalyzedModel(rawModelInfoArr)
    analyzedModel='notUnique';
    ownerModel=rawModelInfoArr(1).ownerModel;
    if~isempty(ownerModel)&&all(strcmp(ownerModel,{rawModelInfoArr.ownerModel}))
        analyzedModelArr={rawModelInfoArr.analyzedModel};
        slashIdxs=strfind(analyzedModelArr,'/');
        if all(~cellfun(@isempty,slashIdxs))
            analyzedAdjusted=analyzedModelArr;
            for i=1:numel(analyzedModelArr)
                curModel=analyzedModelArr{i};
                analyzedAdjusted{i}=curModel(slashIdxs{i}(1)+1:end);
            end
            if isequal(analyzedAdjusted{:})
                analyzedModel=[ownerModel,'/',analyzedAdjusted{1}];
            end
        end
    end
end


