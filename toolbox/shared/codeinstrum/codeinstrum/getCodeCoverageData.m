function cvd=getCodeCoverageData(MATLABFunction)

    cvt=cv.coder.cvtest();
    cvt.settings.decision=true;
    cvt.settings.condition=true;
    cvt.settings.mcdc=true;
    cvt.settings.relationalop=false;
    cvt.options.mcdcMode=SlCov.McdcMode.Masking;

    metricNames={'Decision','Condition','MCDC','RelationalBoundary','Statement','FunEntry','FunExit','FunCall'};
    idx=true(size(metricNames));
    idx(1)=cvt.settings.decision;
    idx(2)=cvt.settings.condition;
    idx(3)=cvt.settings.mcdc;
    idx(4)=cvt.settings.relationalop;
    metricNames(~idx)=[];

    moduleName=codeinstrum.internal.MATLABCoderInstrumenter.buildModuleName(MATLABFunction);
    codeDir=coder.connectivity.MATLABSILPILInterfaceStore.getInstance().getCodeCoverageData(MATLABFunction);
    [trDataFiles,resHitsFile]=codeinstrum.internal.MATLABCoderInstrumenter.getCodeCovDataFiles(MATLABFunction,codeDir);
    codeCovData=SlCov.results.CodeCovData(...
    'traceabilitydbfile',trDataFiles,...
    'resHitsFile',resHitsFile,...
    'name',MATLABFunction,...
    'metricNames',metricNames,...
    'mcdcMode',cvt.options.mcdcMode,...
    'moduleName',moduleName);

    if endsWith(MATLABFunction,'_sil')
        codeCovData.Mode=SlCov.CovMode.SIL;
    else
        codeCovData.Mode=SlCov.CovMode.PIL;
    end

    cvd=cv.coder.cvdata(cvt,codeCovData);

    testRunInfo.runName=sprintf('run %s in %s mode',MATLABFunction,codeCovData.Mode);
    testRunInfo.runId=0;
    testRunInfo.testId=struct('uuid',cvd.uniqueId,'contextType','MC');

    cvd.testRunInfo=testRunInfo;

    if nargout<1
        if rtwprivate('rtwinbat')
            disp('MATLAB Code Coverage report is not launched in BaT or during test execution.');
            lShowReport=false;
        else
            lShowReport=true;
            web -new;
        end

        htmlMetricNames={'statement'};
        if cvt.settings.decision
            htmlMetricNames{end+1}='decision';
        end
        if cvt.settings.condition
            htmlMetricNames{end+1}='condition';
        end
        if cvt.settings.mcdc
            htmlMetricNames{end+1}='mcdc';
        end
        if cvt.settings.relationalop
            htmlMetricNames{end+1}='relationalop';
        end

        codeinstrum.internal.codecov.CodeCovData.htmlReport(codeCovData,...
        'showreport',lShowReport,...
        'radixName',MATLABFunction,...
        'metricNames',htmlMetricNames);
    end
end


