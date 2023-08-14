

function setDisplayIssues(val)
    if~exist('val','var')
        if(strcmpi(get_param(0,'ShowEditTimeIssues'),'on'))
            settingFlag=false;
        else
            settingFlag=true;
        end
    else
        settingFlag=strcmpi(val,'on');
    end
    editControl=edittimecheck.EditTimeEngine.getInstance();

    open_mdls=find_system('type','block_diagram','BlockDiagramType','model');
    open_mdls=[open_mdls;find_system('type','block_diagram','BlockDiagramType','subsystem')];
    open_mdls=[open_mdls;find_system('type','block_diagram','BlockDiagramType','library')];
    if settingFlag
        set_param(0,'ShowEditTimeIssues','on');

        if~isempty(open_mdls)
            editControl.loadCheckModule(open_mdls{1});
        else
            editControl.loadCheckModule("");
        end

        sf('SetLintStatus',true);
        for i=1:length(open_mdls)
            editControl.turnOnErrorsAndWarnings(open_mdls{i});
            showReqTableErrorsAndWarnings(open_mdls{i});
        end
        if(slfeature('EditTimeMismatchCheck')>0)
            Simulink.EditTimeMismatchUtils.turnOnMismatchChecking();
        end
    else

        sf('SetLintStatus',false);
        set_param(0,'ShowEditTimeIssues','off');
        for i=1:length(open_mdls)
            editControl.turnOffErrorsAndWarnings(open_mdls{i});
            clearReqTableErrorsAndWarnings(open_mdls{i});
        end
        if(slfeature('EditTimeMismatchCheck')>0)
            Simulink.EditTimeMismatchUtils.turnOffMismatchChecking();
        end
    end

end

function showReqTableErrorsAndWarnings(open_mdl)
    modelH=get_param(open_mdl,'handle');
    machineId=sf('find','all','machine.simulinkModel',modelH);
    chartIds=sf('get',machineId,'.charts');
    for chartId=chartIds
        if sfprivate('is_requirement_chart',chartId)
            Stateflow.ReqTable.internal.TableManager.findAndHighlightSyntaxErrors(chartId,false,[])
            Stateflow.ReqTable.internal.WarnInvalidVarUsage.warnOnChart(chartId,Stateflow.ReqTable.internal.WarnInvalidVarUsage.OPEN_CONTEXT);
        end
    end
end

function clearReqTableErrorsAndWarnings(open_mdl)
    modelH=get_param(open_mdl,'handle');
    machineId=sf('find','all','machine.simulinkModel',modelH);
    chartIds=sf('get',machineId,'.charts');
    for chartId=chartIds
        if sfprivate('is_requirement_chart',chartId)
            Stateflow.ReqTable.internal.DiagnosticHandler.clearDiagnosticsByType(chartId,...
            Stateflow.ReqTable.internal.DiagnosticType.SyntaxIssue);
            Stateflow.ReqTable.internal.DiagnosticHandler.clearDiagnosticsByType(chartId,...
            Stateflow.ReqTable.internal.DiagnosticType.SemanticIssue);
        end
    end

end

