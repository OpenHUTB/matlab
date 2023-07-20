function cvtest=setMetric(cvtest,metricName,value)

    id=cvtest.id;
    mappedMetricNames=cvi.MetricRegistry.getMappedMetricNames(metricName);
    if~isempty(mappedMetricNames)
        if value==1
            setMetricDataOn(cvtest,mappedMetricNames);
        else
            setMetricDataOff(id,mappedMetricNames);
        end
    else
        enumVal=cvi.MetricRegistry.getEnum(metricName);
        if isempty(enumVal)
            error(message('Slvnv:simcoverage:subsref:InvalidSubscript'));
        end

        if isscalar(value)&&(isnumeric(value)||islogical(value))
            cv('set',id,['testdata.settings.',metricName],logical(value));
        else
            error(message('Slvnv:simcoverage:cvtest:InvalidMetricValue',metricName));
        end
    end

    function setMetricDataOff(id,metricNames)
        metricdataIds=cv('get',id,'testdata.testobjectives');
        for i=1:numel(metricNames)
            cmn=metricNames{i};
            metricenumValue=cvi.MetricRegistry.getEnum(cmn);
            if~isempty(metricdataIds)&&metricenumValue<=numel(metricdataIds)&&metricdataIds(metricenumValue)~=0
                mdid=metricdataIds(metricenumValue);
                assert(strcmpi(cv('get',mdid,'.metricName'),cmn));
                cv('delete',mdid);
                metricdataIds(metricenumValue)=0;
            end
        end
        if~any(metricdataIds)
            cv('set',id,'testdata.testobjectives',[])
        else
            cv('set',id,'testdata.testobjectives',metricdataIds);
        end