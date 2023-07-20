




function cvtest=copyMetricsFromModel(cvtest,modelName)


    settingStr=get_param(modelName,'CovMetricSettings');


    setToOneMetrics=cvi.MetricRegistry.getNamesFromAbbrevs(settingStr);
    allUiMetricNames=cvi.MetricRegistry.getAllSettingsMetricNames();
    setToZeroMetrics=setdiff(allUiMetricNames,setToOneMetrics);

    setToOneMetrics=[setToOneMetrics,cvi.MetricRegistry.getDefaultMetricNames()];


    setMetricOnOff(cvtest,setToOneMetrics,0,1);
    setMetricOnOff(cvtest,setToZeroMetrics,1,0);


    cvs=cvtest.getSlcovSettings;
    cvs.logicBlkShortcircuit=any(settingStr=='s');
    cvs.useTimeInterval=strcmpi(get_param(modelName,'CovUseTimeInterval'),'on');
    cvs.intervalStartTime=get_param(modelName,'CovStartTime');
    cvs.intervalStopTime=get_param(modelName,'CovStopTime');
    cvs.covBoundaryRelTol=get_param(modelName,'CovBoundaryRelTol');
    cvs.covBoundaryAbsTol=get_param(modelName,'CovBoundaryAbsTol');

    testId=cvtest.id;

    cv('set',testId,'testdata.mcdcMode',SlCov.getMcdcMode(modelName));

    value=get_param(modelName,'CovModelRefEnable');
    cv('set',testId,'testdata.mldref_enable',value);

    value=get_param(modelName,'CovModelRefExcluded');
    cv('set',testId,'testdata.mldref_excludedModels',value);

    value=get_param(modelName,'RecordCoverage');
    cv('set',testId,'testdata.mldref_excludeTopModel',~strcmpi(value,'on'));

    value=get_param(modelName,'CovExternalEMLEnable');
    cv('set',testId,'testdata.covExternalEMLEnable',strcmpi(value,'on'));

    value=get_param(modelName,'CovSFcnEnable');
    cv('set',testId,'testdata.covSFcnEnable',strcmpi(value,'on'));

    value=get_param(modelName,'CovForceBlockReductionOff');
    cv('set',testId,'testdata.forceBlockReductionOff',strcmpi(value,'on'));

    value=get_param(modelName,'CovExcludeInactiveVariants');
    cv('set',testId,'testdata.excludeInactiveVariants',strcmpi(value,'on'));

    value=get_param(modelName,'CovFilter');
    cv('set',testId,'testdata.covFilter',value);

    value=get_param(modelName,'Description');
    cv('SetDescription',testId,value);

    value=get_param(modelName,'CovFilter');
    if~isempty(value)
        value=split(value,',')';
        if numel(value)==1
            value=value{1};
        end
    end
    cv('set',testId,'testdata.covFilter',value);


    function setMetricOnOff(cvtest,metricNames,fromValue,toValue)

        for idx=1:numel(metricNames)
            cmn=metricNames{idx};
            currentValue=getSettingsMetricValue(cvtest,cmn);
            if currentValue==fromValue
                setMetric(cvtest,cmn,toValue);
            end
        end


