
function setMetricDataOn(cvtest,metricNames)
    metricdataIds=cv('get',cvtest.id,'testdata.testobjectives');

    for i=1:numel(metricNames)
        cmn=metricNames{i};
        metricenumValue=cvi.MetricRegistry.getEnum(cmn);
        if~isempty(metricdataIds)&&metricenumValue<numel(metricdataIds)&&metricdataIds(metricenumValue)~=0
            assert(strcmpi(cv('get',metricdataIds(metricenumValue),'.metricName'),cmn));
        else
            metricdataIds(metricenumValue)=cv('new','metricdata','.metricName',cmn,'.metricenumValue',metricenumValue);
        end
    end
    cv('set',cvtest.id,'testdata.testobjectives',metricdataIds);