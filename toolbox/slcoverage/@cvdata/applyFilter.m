function res=applyFilter(cvd)



    try
        res=false;




        fA=cvi.TopModelCov.getFilterApplied(cvd.rootId);
        if isempty(cvd.filterData)&&isempty(cvd.filter)&&...
            isempty(cvd.filterApplied)&&(isempty(fA)||isempty(fA(1).fileNameId))
            return;
        end

        modelH=cvdata.findTopModelHandle(cvd);

        [modelFilterStatusChanged,datedFilterName]=cvi.TopModelCov.setUpFiltering(modelH,cvd);
        dataFilterStatusChanged=~strcmpi(cvd.filterApplied,datedFilterName);

        if~modelFilterStatusChanged&&~dataFilterStatusChanged
            return;
        end

        cvd.filterApplied=datedFilterName;
        res=true;

        if~((SlCov.CovMode.isGeneratedCode(cvd.simMode)&&...
            isa(cvd.codeCovData,'SlCov.results.CodeCovData'))||...
            (cvd.isSimulinkCustomCode&&...
            isa(cvd.sfcnCovData,'SlCov.results.CodeCovDataGroup')))
            applyFilterOnCvdata(cvd);
        end
    catch MEx
        rethrow(MEx);
    end
end

function applyFilterOnCvdata(cvd)
    [metricNames,toMetricNames]=getEnabledMetricNames(cvd);
    id=cvd.id;
    rootId=cvd.rootId;
    dataMetrics=cvd.metrics;
    for metricI=metricNames(:)'
        metric=metricI{1};
        if~strcmpi(metric,'testobjectives')
            metricData=dataMetrics.(metric);
            if~isempty(metricData)&&...
                ~strcmpi(metric,'sigrange')&&~strcmpi(metric,'sigsize')
                metricEnumVal=cvi.MetricRegistry.getEnum(metric);
                metricData=cv('ProcessData',rootId,metricEnumVal,metricData);
            end
            if id==0
                cvd.localData.metrics.(metric)=metricData;
            else
                cv('set',id,['testdata.data.',metric],metricData);
            end
        end
    end

    if~isempty(toMetricNames)
        dataMetrics=cvd.metrics.testobjectives;
        for metricI=toMetricNames(:)'
            metric=metricI{1};
            metricData=dataMetrics.(metric);
            if~isempty(metricData)
                metricenumValue=cvi.MetricRegistry.getEnum(metric);
                metricdataId=cv('new','metricdata','.metricName',metric,'.metricenumValue',metricenumValue);
                cv('set',metricdataId,'.data.rawdata',metricData,'.size',numel(metricData));
                metricData=cv('ProcessTOData',rootId,metricdataId);
                cv('delete',metricdataId);

                if id==0
                    cvd.localData.metrics.testobjectives.(metric)=metricData;
                else
                    metricdataIds=cv('get',id,'.testobjectives');
                    cv('set',metricdataIds(metricenumValue),'.data.rawdata',metricData);
                end
            end
        end
    end
end
