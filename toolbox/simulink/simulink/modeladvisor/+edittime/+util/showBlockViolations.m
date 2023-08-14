function widget=showBlockViolations(model,blockHandle,startWithViolationType)






    advisorViolations=edittime.util.getAdvisorViolations(model,blockHandle);

    widgetDataMA=createDiagnosticWidgetData(advisorViolations,model,true);

    diagnosticViolations=edittime.util.getDiagnosticViolations(model,blockHandle);
    widgetDataSlDiag=createDiagnosticWidgetData(diagnosticViolations,model,false);

    widgetData=reorder([widgetDataSlDiag,widgetDataMA],startWithViolationType);

    spec=Simulink.output.targetspecifiers.editor(blockHandle);

    if slfeature('EditTimeJustification')>0
        widget=Simulink.output.DiagnosticWidget(widgetData,spec);
    else
        widgetConfig=Simulink.output.DiagnosticWidget.getDefaultWidgetConfiguration();
        widgetConfig.Suppression.ClientHandlesJustification=true;
        widget=Simulink.output.DiagnosticWidget(widgetData,spec,widgetConfig);
    end

    widget.show();
end

function output=createDiagnosticWidgetData(violations,model,isMA)
    output=[];
    checkMgr=edittimecheck.CheckManager.getInstance;

    for i=1:length(violations)

        severity=Simulink.output.utils.Severity.Warning;
        if(violations(i).getViolationStatus()==ModelAdvisor.CheckStatus.Failed)
            severity=Simulink.output.utils.Severity.Error;
        end

        if violations(i).getViolationStatus()==ModelAdvisor.CheckStatus.Justified
            continue;
        end

        json=checkMgr.getSLdiagnosticJSON(violations(i));

        if slfeature('MATLABAuthoredEdittimeChecks')
            json=addCompileCaret(model,json,violations(i));
        end


        if isMA

            componentStr='Model Advisor';
            helpCB=@()helpViolation(violations(i));

            if slfeature('EditTimeJustification')>0

                ignoreCB=@(justificationComment)...
                JustifyViolation(model,violations(i),...
                justificationComment);

                restoreCB=@()restoreJustificaton(model,violations(i));

            else

                ignoreCB=@()ignoreViolation(model,violations(i));
                restoreCB=function_handle.empty;
            end
        else
            componentStr='';
            helpCB=function_handle.empty;
            ignoreCB=function_handle.empty;
            restoreCB=function_handle.empty;
        end

        dataObj=Simulink.output.DiagnosticWidgetData(MSLDiagnostic(json),...
        'Severity',severity,...
        'Component',componentStr,...
        'HelpFcn',helpCB,...
        'SuppressFcn',ignoreCB,...
        'RestoreFcn',restoreCB);

        output=[output,dataObj];
    end

end

function helpViolation(violation)
    if~isempty(violation)
        cm=edittimecheck.CheckManager.getInstance;
        helpLinks=cm.getHelp(violation);
        map_path=['mapkey:',helpLinks.mapkey];
        topic_id=helpLinks.topicid;
        if~isempty(map_path)&&~isempty(topic_id)&&...
            ~strcmpi(topic_id,'create_custom_checks_help_popup')
            helpview(map_path,topic_id,'CSHelpWindow');
        else
            ModelAdvisor.internal.launchCustomHelp(violation.CheckID);
        end
    end
end

function ignoreViolation(~,violation)
    prop=slcheck.getPropertySchema;
    prop.value=strrep(Simulink.ID.getFullName(violation.Data),newline,' ');
    prop.checkIDs={violation.CheckID};
    exEditor=Advisor.getExclusionEditor(bdroot(Simulink.ID.getFullName(violation.Data)));
    exEditor.Controller.addExclusion(prop,true);
end

function JustifyViolation(model,RDObj,justificationComment)

    logDDUXForETUIJustification()
    Advisor.Utils.Justification.justifyViolation(model,...
    RDObj,...
    justificationComment,...
    RDObj.CheckID);
    Advisor.Utils.Justification.serialize(model);
end

function restoreJustificaton(model,RDObj)
    Advisor.Utils.Justification.unjustifyViolation(model,RDObj);
    Advisor.Utils.Justification.serialize(model);
end

function logDDUXForETUIJustification()
    persistent value;
    if(isempty(value))
        value=true;
        Simulink.DDUX.logData('ET_JUSTIFY','etuijustification',value);
    end
end

function json=addCompileCaret(model,json,violation)
    isCompileNeeded=false;
    config=ModelAdvisor.getModelConfiguration(bdroot(model));

    if isempty(config)
        config=ModelAdvisor.getDefaultConfiguration();
    end

    if isempty(config)
        am=Advisor.Manager.getInstance;
        if isempty(am.slCustomizationDataStructure.CheckIDMap)
            am.loadslCustomization();
            disp('One time cache generating ...');
        end
        if am.slCustomizationDataStructure.CheckIDMap.isKey(violation.CheckID)
            checkObj=am.slCustomizationDataStructure.checkCellArray(am.slCustomizationDataStructure.CheckIDMap(violation.CheckID));
            if strcmp(checkObj{1}.CallbackContext,'PostCompile')
                isCompileNeeded=true;
            end
        end
    end
    if~isempty(violation.CheckID)&&~isempty(config)&&~strncmp(fliplr(config),'tam.',4)
        fid=fopen(config);
        raw=fread(fid,inf);
        str=char(raw');
        fclose(fid);
        configjson=jsondecode(str);
        for j=1:length(configjson.Tree)



            if iscell(configjson.Tree)
                if strcmp(configjson.Tree{j}.checkid,violation.CheckID)&&...
                    (configjson.Tree{j}.iscompile)&&isempty(strfind(violation.Title,'^'))
                    isCompileNeeded=true;
                end
            else
                if strcmp(configjson.Tree(j).checkid,violation.CheckID)&&...
                    (configjson.Tree(j).iscompile)&&isempty(strfind(violation.Title,'^'))
                    isCompileNeeded=true;
                end
            end
        end
    end
    if isCompileNeeded
        idx=strfind(json,'message');
        json=[json(1:idx(1)+9),'^ ',json(idx(1)+10:end)];
    end
end


function violations=reorder(violations,startWithViolationType)
    errors=[];warnings=[];
    for i=1:length(violations)
        if(violations(i).Severity==Simulink.output.utils.Severity.Error)
            errors=[errors,violations(i)];%#ok<*AGROW>
        end
        if(violations(i).Severity==Simulink.output.utils.Severity.Warning)
            warnings=[warnings,violations(i)];
        end
    end


    if(startWithViolationType==ModelAdvisor.CheckStatus.Failed)
        violations=[errors,warnings];
    elseif(startWithViolationType==ModelAdvisor.CheckStatus.Warning)
        violations=[warnings,errors];
    end
end

