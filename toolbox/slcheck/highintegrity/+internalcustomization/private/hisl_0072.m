function hisl_0072

    rec=getNewCheckObject('mathworks.hism.hisl_0072',false,@hCheckAlgo,'None');
    rec.SupportLibrary=false;
    rec.SupportExclusion=false;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setLicense({HighIntegrity_License});

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:hism:hisl_0072_action_description');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)

    violations=[];
    result={};
    system=bdroot(system);


    tunableVarsMdls=modeladvisorprivate('mdladv_mdlref','FindModelsWithModelRefAndTunableVars',system);

    if isempty(tunableVarsMdls)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


        if(mdladvObj.TreatAsMdlref)&&~isempty(get_param(system,'TunableVars'))&&strcmp('Inlined',get_param(system,'DefaultParameterBehavior'))
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0072_warn');
            ModelAdvisor.ResultDetail.setData(vObj,'FileName',system);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0072_rec_action');
            violations=[violations;vObj];
        end
    else
        for i=1:length(tunableVarsMdls)
            if~slreportgen.utils.isModelLoaded(tunableVarsMdls{i})
                load_system(tunableVarsMdls{i});
                paramVal=get_param(tunableVarsMdls{i},'TunableVars');
                defBehavior=get_param(tunableVarsMdls{i},'DefaultParameterBehavior');
                close_system(tunableVarsMdls{i});
            else
                paramVal=get_param(tunableVarsMdls{i},'TunableVars');
                defBehavior=get_param(tunableVarsMdls{i},'DefaultParameterBehavior');
            end
            if~isempty(paramVal)&&strcmp('Inlined',defBehavior)
                vObj=ModelAdvisor.ResultDetail;
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0072_warn');
                ModelAdvisor.ResultDetail.setData(vObj,'FileName',tunableVarsMdls{i});
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0072_rec_action');
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end
end

function result=checkActionCallback(~)

    UpdatedList={};
    result=ModelAdvisor.Paragraph;
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);

    ch_result=mdladvObj.getCheckResult('mathworks.hism.hisl_0072');
    failedList=ch_result{1}.ListObj;

    if~isempty(failedList)
        for i=1:length(failedList)
            if~slreportgen.utils.isModelLoaded(failedList{i})
                load_system(failedList{i});
                UpdatedList{end+1}=get_param(failedList{i},'TunableVars');
                close_system(failedList{i});
            else
                UpdatedList{end+1}=get_param(failedList{i},'TunableVars');
            end
        end
        modeladvisorprivate('mdladv_mdlref','ConvertTunableVarsToParameterObjects',failedList);
    end

    UpdatedList=unique(UpdatedList);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);



    if~isempty(UpdatedList)
        ft.setInformation(DAStudio.message('ModelAdvisor:hism:hisl_0072_action'));
        modText=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:hism:hisl_0072_post_modification_updatetext'));
        modText.setColor('warn');
    else
        ft.setInformation(DAStudio.message('ModelAdvisor:hism:hisl_0072_invalid_warn'));
    end

    ft.setListObj(cellfun(@(x)strsplit(x,','),UpdatedList,'UniformOutput',false));
    result.addItem(ft.emitContent);

    if~isempty(UpdatedList)
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(modText);
    end
end
