function[bRecordCoverage,bMdlRefCoverage,bUseCoverageFilter,...
    bCoverageFilterFileName,metricSettings]=getModelCoverageSettings(model)



    recordCoverage=get_param(model,'RecordCoverage');
    bRecordCoverage=strcmp(recordCoverage,'on');


    mdlRefCoverage=get_param(model,'CovModelRefEnable');
    bMdlRefCoverage=any(strcmp(mdlRefCoverage,{'on','all'}));


    metricSettings=get_param(model,'CovMetricSettings');

    bCoverageFilterFileName=get_param(model,'CovFilter');
    bUseCoverageFilter=~isempty(bCoverageFilterFileName)&&...
    (bRecordCoverage||bMdlRefCoverage);
end
