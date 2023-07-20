function[metricStruct,traceStruct]=perform_operation(lhs_cvdata,rhs_cvdata,opFcn,opChar,joinedAggregatedTestInfo)












    cvdArray=[lhs_cvdata,rhs_cvdata];

    metricNames=[];
    toMetricNames=[];
    numCvdata=numel(cvdArray);
    cvdNumRuns=zeros(1,numCvdata);

    for k=1:numCvdata

        if~valid(cvdArray(k))
            error(message('Slvnv:simcoverage:cvdata:InvalidCvData',k));
        end

        [curr_metricNames,curr_toMetricNames]=getEnabledMetricNames(cvdArray(k));
        metricNames=[metricNames;curr_metricNames'];%#ok<AGROW>
        toMetricNames=[toMetricNames;curr_toMetricNames'];%#ok<AGROW>

        cvdNumRuns(k)=getNumRuns(cvdArray(k));
    end

    metricNames=unique(metricNames);
    toMetricNames=unique(toMetricNames);

    traceOn=any([cvdArray.traceOn]);


    cvdMetrics=[cvdArray.metrics];

    metricStruct=[];
    traceStruct=[];


    cvi.ReportData.updateDataIdx(cvdArray(1));
    rootId=cvdArray(1).rootID;






    modelcovId=cv('get',rootId,'.modelcov');
    [modelHandle,activeTest,currentTest]=...
    cv('get',modelcovId,'.handle','.activeTest','.currentTest');
    if(modelHandle==0)&&(activeTest==0)&&(currentTest==0)
        cv('set',modelcovId,'.currentTest',cvdArray(1).id);
    end



    for metricI=metricNames(:)'
        metric=metricI{1};
        isSigrange=false;
        blankFiller=0;

        if strcmpi(metric,'sigrange')||strcmpi(metric,'sigsize')
            isSigrange=true;
            blankFiller=NaN;
        elseif(strcmp(metric,'tableExec'))
            for k=2:numCvdata
                cvi.TopModelCov.checkMetricConsistency(rootId,cvdArray(k).rootID,true);
            end
        end

        cvMetricData={cvdMetrics.(metric)};
        collectedMetricData=concatMetric(cvMetricData,blankFiller);
        metricData=cvdata.processMetric(rootId,metric,collectedMetricData,opFcn,opChar);

        if~isempty(metricData)&&~isSigrange
            metricEnumVal=cvi.MetricRegistry.getEnum(metric);
            metricData=cv('ProcessData',rootId,metricEnumVal,metricData);
        end
        metricStruct.(metric)=metricData;


        if traceOn&&~isSigrange
            cvTraceData=cell(1,numCvdata);
            for k=1:numCvdata
                if~isempty(cvdArray(k).trace)&&isfield(cvdArray(k).trace,metric)
                    cvTraceData{k}=cvdArray(k).trace.(metric);
                else
                    cvTraceData{k}=[];
                end
            end

            traceStruct.(metric)=processTrace(cvTraceData,collectedMetricData);
        end
    end

    if~isempty(toMetricNames)
        tmpMetricStruct=[];
        for metricI=toMetricNames(:)'
            metric=metricI{1};
            cvMetricData=cell(1,numCvdata);

            for k=1:numCvdata
                if isfield(cvdArray(k).metrics,'testobjectives')&&...
                    isfield(cvdArray(k).metrics.testobjectives,metric)
                    cvMetricData{k}=[cvdArray(k).metrics.testobjectives.(metric)];
                end
            end

            collectedMetricData=concatMetric(cvMetricData,0);
            metricData=cvdata.processMetric(rootId,metric,collectedMetricData,opFcn,opChar);

            if~isempty(metricData)
                metricenumValue=cvi.MetricRegistry.getEnum(metric);
                metricdataId=cv('new','metricdata','.metricName',metric,'.metricenumValue',metricenumValue);
                cv('set',metricdataId,'.data.rawdata',metricData,'.size',numel(metricData));
                metricData=cv('ProcessTOData',rootId,metricdataId);
                cv('delete',metricdataId);
            end
            tmpMetricStruct.(metric)=metricData;

            if traceOn
                cvTraceData=cell(1,numCvdata);
                for k=1:numCvdata
                    if~isempty(cvdArray(k).trace)&&...
                        isfield(cvdArray(k).trace,'testobjectives')&&...
                        isfield(cvdArray(k).trace.testobjectives,metric)
                        cvTraceData{k}=[cvdArray(k).trace.testobjectives.(metric)];
                    else
                        cvTraceData{k}=[];
                    end
                end

                tmpTraceStruct.(metric)=processTrace(cvTraceData,collectedMetricData);
            end
        end
        metricStruct.testobjectives=tmpMetricStruct;

        if traceOn
            traceStruct.testobjectives=tmpTraceStruct;
        end

    end



    function trace=processTrace(traceData,metricData)
        try
            trace=[];
            if(opChar~='+')
                return;
            end

            for i=1:length(traceData)
                if isempty(traceData{i})
                    if(cvdNumRuns(i)>1)

                        traceData{i}=zeros(size(metricData,1),cvdNumRuns(i));
                    elseif~isempty(metricData)



                        traceData{i}=metricData(:,i);
                    end
                end
            end

            trace=cell2mat(traceData);
            assert(isempty(trace)||(numel(joinedAggregatedTestInfo)==size(trace,2)));
        catch MEx
            rethrow(MEx);
        end
    end
end


function numRuns=getNumRuns(cvd)
    numRuns=numel(cvd.aggregatedTestInfo);
    if(numRuns==0)

        numRuns=1;
    end
end


function collectedMetricData=concatMetric(metricArr,blankFiller)

    emptyIdxs=cellfun(@isempty,metricArr);
    if any(emptyIdxs)


        nonEmptyIdx=find(~emptyIdxs,1);
        if~isempty(nonEmptyIdx)
            placeholder=ones(length(metricArr{nonEmptyIdx}),1).*blankFiller;
            metricArr(emptyIdxs)={placeholder};
        end
    end

    collectedMetricData=cell2mat(metricArr);
end

