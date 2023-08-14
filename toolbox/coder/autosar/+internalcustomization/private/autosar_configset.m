function autosar_configset




    rec=ModelAdvisor.Check('mathworks.autosar.autosar_configset');
    rec.Title=DAStudio.message('autosarstandard:autosarchecks:autosar_configset_title');
    rec.TitleTips=DAStudio.message('autosarstandard:autosarchecks:autosar_configset_tip');
    rec.CSHParameters.MapKey='autosar';
    rec.CSHParameters.TopicID=rec.Id;

    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'autosarstandard:autosarchecks:autosar_configset',@hCheckAlgo),'None','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.ConfigurationParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ConfigurationParameterStyle'});

    rec.Value=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=true;

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    rec.setLicense(autosar_license);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,autosar_group);
end


function violations=hCheckAlgo(system)

    violations={};

    if~strcmp(system,bdroot(system))
        system=bdroot(system);
    end

    cs=getActiveConfigSet(system);

    autosarCompliant=get_param(system,'AutosarCompliant');

    if~strcmp(autosarCompliant,'on')
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','SystemTargetFile',...
        'CurrentValue',get_param(system,'SystemTargetFile'),...
        'RecommendedValue',{'autosar.tlc,autosar_adaptive.tlc'});
        violations=[violations;vObj];
        return;
    end

    if isempty(violations)





        if strcmp(get_param(system,'CodeInterfacePackaging'),'Reusable function')

            violations=[violations;checkCS(system,'ERTFilePackagingFormat','Modular',cs)];
            violations=[violations;checkCS(system,'InlineParams','on',cs)];

        end


        violations=[violations;checkCS(system,'CombineOutputUpdateFcns','on',cs)];
        violations=[violations;checkCS(system,'SupportContinuousTime','off',cs)];
        violations=[violations;checkCS(system,'SupportNonInlinedSFcns','off',cs)];
        violations=[violations;checkCS(system,'SupportNonFinite','off',cs)];
        violations=[violations;checkCS(system,'RateTransitionBlockCode','Inline',cs)];
        violations=[violations;checkCS(system,'SFInvalidInputDataAccessInChartInitDiag',{'warning','error'},cs)];
        violations=[violations;checkCS(system,'SimulationMode',{'normal','external','Software-in-the-loop (SIL)','Processor-in-the-loop (PIL)'},cs)];

        if~Simulink.CodeMapping.isAutosarAdaptiveSTF(system)

            violations=[violations;checkCS(system,'SupportComplex','off',cs)];
            maxShortNameLength=get_param(system,'AutosarMaxShortNameLength');

            if~((32<=maxShortNameLength)&&(maxShortNameLength<=128))

                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','AutosarMaxShortNameLength','CurrentValue',get_param(system,'AutosarMaxShortNameLength'),'RecommendedValue','Range(32,128)');
                violations=[violations;vObj];

            end

        end


        if autosar.validation.ExportFcnValidator.isExportFcn(system)&&...
            strcmp(get_param(system,'SampleTimeConstraint'),'STIndependent')&&...
            strcmp(get_param(system,'SolverMode'),'SingleTasking')

            violations=[violations;checkCS(system,'AutoInsertRateTranBlk','off',cs)];

        end

    end
end

function vObj=checkCS(system,paramStr,recVal,cs)












    vObj='';

    if~cs.isConfigSetParam(paramStr)

        return;
    end

    if iscell(recVal)
        status=any(strcmp(get_param(system,paramStr),recVal));
        recValStr=strjoin(recVal,',');
    else
        status=strcmp(get_param(system,paramStr),recVal);
        recValStr=recVal;
    end


    if~status
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter',paramStr,'CurrentValue',get_param(system,paramStr),'RecommendedValue',recValStr);
    end
end

function cs=getActiveConfigSet(system)

    systemObj=get_param(bdroot(system),'object');
    cs=systemObj.getActiveConfigSet();



    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet();
    end
end

function result=checkActionCallback(taskobj)



    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);
    system=bdroot(mdladvObj.System);

    ch_result=mdladvObj.getCheckResult(taskobj.MAC);
    failingObjs=ch_result{1}.TableInfo;

    if isempty(failingObjs)
        return;
    end

    result=ModelAdvisor.Paragraph;




    if isa(getActiveConfigSet(bdroot(system)),'Simulink.ConfigSetRef')
        maText=ModelAdvisor.Text;
        maText.Content=DAStudio.message...
        ('Advisor:engine:CCOFModelParamFixConfSetRef');
        result.addItem(maText.emitContent);
        return;
    end


    lengthObj=size(failingObjs);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);

    for count=1:lengthObj(1)

        param=getParam(failingObjs{count,1});

        if strcmp(param,'SystemTargetFile')

            set_param(system,param,'autosar.tlc');
            ft.setInformation(DAStudio.message('autosarstandard:autosarchecks:autosar_configset_action_compliance'));
            result.addItem(ft.emitContent);
            return;

        elseif strcmp(param,'SimulationMode')
            val='normal';
        elseif strcmp(param,'AutosarMaxShortNameLength')
            val=128;
        elseif strcmp(param,'SFInvalidInputDataAccessInChartInitDiag')
            val='warning';
        else
            val=failingObjs{count,3};
        end

        if((strcmp(param,'ERTFilePackagingFormat')||...
            strcmp(param,'InlineParams'))&&...
            ~strcmp(get_param(system,'CodeInterfacePackaging'),'Reusable function'))||...
            ((strcmp(param,'AutosarMaxShortNameLength')||...
            strcmp(param,'SupportComplex'))&&...
            Simulink.CodeMapping.isAutosarAdaptiveSTF(system))||...
            (strcmp(param,'AutoInsertRateTranBlk')&&...
            (~autosar.validation.ExportFcnValidator.isExportFcn(system)&&...
            ~strcmp(get_param(system,'SampleTimeConstraint'),'STIndependent')&&...
            ~strcmp(get_param(system,'SolverMode'),'SingleTasking')))




            continue;
        end

        set_param(system,param,val);

    end



    ft.setInformation(DAStudio.message('autosarstandard:autosarchecks:autosar_configset_action'));
    result.addItem(ft.emitContent);

end

function param=getParam(resultParam)




    content=resultParam.Content;


    [startI,endI]=regexp(content,'\(.*\)');
    if isempty(startI)


        param=content;
    else
        param=content(startI+1:endI-1);
    end
end
