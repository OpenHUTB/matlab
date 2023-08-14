function cvtest=setAllMetric(cvtest,value)




    ms=cvtest.settings;
    metricNames=fields(ms);
    for idx=1:numel(metricNames)
        cmn=metricNames{idx};
        mv=cvtest.settings.(cmn);
        if mv~=value
            setMetric(cvtest,cmn,value);
        end
    end



