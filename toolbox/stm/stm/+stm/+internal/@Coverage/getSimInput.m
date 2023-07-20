



function simIn=getSimInput(this,simIn,fastRestart)
    if~isempty(this.harnessName)
        this.initHarnessCoverageSettings;
    end


    simIn=simIn.setModelParameter(...
    'RecordCoverage',getRecordCoverage(this),...
    'CovHtmlReporting','off');

    if this.coverageSettings.CollectingCoverage

        simIn=customizeCoverageSettings(this,simIn);
    elseif~fastRestart

        simIn=simIn.setModelParameter('CovEnable','off',...
        'CovModelRefEnable','off');
    end

    if~fastRestart
        simIn=simIn.setModelParameter('CovShowResultsExplorer','off');
    end
end

function recordCoverage=getRecordCoverage(this)
    if this.coverageSettings.RecordCoverage
        recordCoverage='on';
    else
        recordCoverage='off';
    end
end

function simIn=customizeCoverageSettings(this,simIn)
    simIn=simIn.setModelParameter(...
    'CovEnableCumulative','off',...
    'CovSaveSingleToWorkspaceVar','on',...
    'CovSaveName',stm.internal.Coverage.CovSaveName,...
    'CovExternalEMLEnable','on',...
    'CovSFcnEnable','on',...
    'CovPath','/',...
    'CovFilter','',...
    'CovSaveOutputData','off');

    simIn=setModelReferenceCoverage(simIn,this.getModelToRun,...
    this.getMdlRefValue);

    simIn=setCovMetricSettings(this,simIn);
end

function simIn=setModelReferenceCoverage(simIn,modelToRun,mdlRefValue)
    param='CovModelRefEnable';
    currentValue=get_param(modelToRun,param);
    if strcmp(mdlRefValue,'on')&&strcmp(currentValue,'filtered')

    else
        simIn=simIn.setModelParameter(param,mdlRefValue);
    end
end

function simIn=setCovMetricSettings(this,simIn)
    param='CovMetricSettings';
    oldSettings=get_param(this.getModelToRun,param);
    newSettings=stm.internal.Coverage.getCovMetricSettings(...
    oldSettings,this.coverageSettings.MetricSettings);


    simIn=simIn.setModelParameter(param,[newSettings,'e']);
end
