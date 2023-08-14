function showSubsystemViolations(model,startWithViolationType)


    if~exist('model','var')
        model=gcs;
    end
    if~exist('startWithViolationType','var')
        startWithViolationType=ModelAdvisor.CheckStatus.Warning;
    end

    blks=find_system(model,'searchdepth',1);
    violations=[];

    idx=findTopmostAndRightMostBlock(blks);
    for i=1:length(blks)
        violations=[violations,edittime.util.getEditTimeViolations(bdroot(model),get_param(blks{i},'Handle'),startWithViolationType)];%#ok<*AGROW> 
        try
            ports=get_param(blks{i},'PortHandles');
            for j=1:length(ports.Outport)
                violations=[violations...
                ,edittime.util.getEditTimeViolations(bdroot(model),ports.Outport(j),startWithViolationType)];
            end
            for j=1:length(ports.Inport)
                violations=[violations...
                ,edittime.util.getEditTimeViolations(bdroot(model),ports.Inport(j),startWithViolationType)];
            end
        catch E
            if(strcmp(E.identifier,'Simulink:Commands:ParamUnknown'))


            end
        end
    end


    widgetData=createDiagnosticWidgetData(violations,model);
    spec=Simulink.output.targetspecifiers.editor(get_param(blks{idx},'Handle'));
    widget=Simulink.output.DiagnosticWidget(widgetData,spec);
    widget.show();
end



function idx=findTopmostAndRightMostBlock(blks)
    position=[];
    for i=1:length(blks)
        try
            pos=get_param(blks{i},'Position');
        catch ME %#ok<*NASGU> 
            pos=0;
        end
        position=[position,pos(1)];%#ok<AGROW> 
    end
    [~,idx]=sort(position,'descend');
    pos2=[];
    for k=1:5
        try
            pos=get_param(blks{idx(k)},'Position');
        catch ME %#ok<*NASGU> 
            pos=[0,1000];
        end
        pos2=[pos2,pos(2)];
    end
    [~,idx1]=min(pos2);
    idx=idx(idx1);
end



function output=createDiagnosticWidgetData(violations,model,~)
    output=[];
    checkMgr=edittimecheck.CheckManager.getInstance;
    for i=1:length(violations)

        severity=Simulink.output.utils.Severity.Warning;
        if(violations(i).getViolationStatus()==ModelAdvisor.CheckStatus.Failed)
            severity=Simulink.output.utils.Severity.Error;
        end

        componentStr='';
        helpCB=function_handle.empty;
        ignoreCB=function_handle.empty;

        if(violations(i).getViolationStatus()==ModelAdvisor.CheckStatus.Warning)
            componentStr='Model Advisor';
            helpCB=@()helpViolation(violations(i));
            ignoreCB=@()ignoreViolation(model,violations(i));
        end
        dataObj=Simulink.output.DiagnosticWidgetData(MSLDiagnostic(checkMgr.getSLdiagnosticJSON(violations(i))),...
        'Severity',severity,'Component',componentStr,'HelpFcn',helpCB,'SuppressFcn',ignoreCB);
        output=[output,dataObj];
    end

end

function helpViolation(violation)
    if~isempty(violation)
        cm=edittimecheck.CheckManager.getInstance;
        helpLinks=cm.getHelp(violation);
        map_path=['mapkey:',helpLinks.mapkey];
        topic_id=helpLinks.topicid;
        if~isempty(map_path)&&~isempty(topic_id)
            helpview(map_path,topic_id,'CSHelpWindow');
        else
            ModelAdvisor.internal.launchCustomHelp(violation.CheckID);
        end
    end
end

function ignoreViolation(model,violation)
    prop=slcheck.getPropertySchema;
    prop.value=strrep(Simulink.ID.getFullName(violation.Data),newline,' ');
    prop.checkIDs={violation.CheckID};
    exEditor=Advisor.getExclusionEditor(bdroot(Simulink.ID.getFullName(violation.Data)));
    exEditor.Controller.addExclusion(prop,true);
end

