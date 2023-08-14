function hisf_0011

    rec=getNewCheckObject('mathworks.hism.hisf_0011',false,@hCheckAlgo,'None');
    rec.SupportLibrary=false;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    myAction=ModelAdvisor.Action;
    myAction.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    myAction.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    myAction.setCallbackFcn(@hActionCallback);
    rec.setAction(myAction);


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)
    violations=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;





    if~strcmpi(get_param(bdroot(system),'IntegerOverflowMsg'),'error')
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',bdroot(system),'Parameter','IntegerOverflowMsg','CurrentValue',get_param(bdroot(system),'IntegerOverflowMsg'),'RecommendedValue','error');
        violations=[violations;vObj];
    end


    if~strcmpi(get_param(bdroot(system),'SignalRangeChecking'),'error')
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',bdroot(system),'Parameter','SignalRangeChecking','CurrentValue',get_param(bdroot(system),'SignalRangeChecking'),'RecommendedValue','error');
        violations=[violations;vObj];
    end



    allCharts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    allCharts=mdlAdvObj.filterResultWithExclusion(allCharts);

    if~isempty(allCharts)
        allMachineIds=unique(cellfun(@(x)x.Machine.Id,allCharts));

        for i=1:length(allMachineIds)
            mach=idToHandle(sfroot,allMachineIds(i));

            if~mach.Debug.RunTimeCheck.CycleDetection
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Model',mach.Name,'Parameter','Detect Cycles','CurrentValue','off','RecommendedValue','on');
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end




    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.TruthTable'},true);
    sfObjs=mdlAdvObj.filterResultWithExclusion(sfObjs);

    for i=1:length(sfObjs)

        if~strcmpi(sfObjs{i}.UnderSpecDiagnostic,'error')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Block',sfObjs{i},'Parameter','UnderSpecDiagnostic','CurrentValue',sfObjs{i}.UnderSpecDiagnostic,'RecommendedValue','error');
            violations=[violations;vObj];%#ok<AGROW>
        end

        if~strcmpi(sfObjs{i}.OverspecDiagnostic,'error')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Block',sfObjs{i},'Parameter','UnderSpecDiagnostic','CurrentValue',sfObjs{i}.UnderSpecDiagnostic,'RecommendedValue','error');
            violations=[violations;vObj];%#ok<AGROW>
        end

    end
end

function result=hActionCallback(~)
    result=ModelAdvisor.Paragraph;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    system=getfullname(mdladvObj.System);

    inputParams=mdladvObj.getInputParameters;

    systemObj=get_param(bdroot(system),'object');
    cs=systemObj.getActiveConfigSet();

    if isa(cs,'Simulink.ConfigSetRef')
        mdladvObj.setActionEnable(false);
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(false);
        ft.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamFixConfSetRef'));
        result=ft;
        return;
    end





    set_param(bdroot(system),'IntegerOverflowMsg','error');



    set_param(bdroot(system),'SignalRangeChecking','error');




    allCharts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    allCharts=mdladvObj.filterResultWithExclusion(allCharts);

    if~isempty(allCharts)
        allMachineIds=unique(cellfun(@(x)x.Machine.Id,allCharts));
        noGo=false(1,numel(allMachineIds));
        for i=1:length(allMachineIds)
            try
                mach=idToHandle(sfroot,allMachineIds(i));
                mach.Debug.RunTimeCheck.CycleDetection=true;
            catch
                noGo(i)=true;
            end
        end
        part2NoGo=arrayfun(@(x)idToHandle(sfroot,x),allMachineIds(noGo),'UniformOutput',0);
    else
        part2NoGo=[];
    end



    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.TruthTable'},true);
    sfObjs=mdladvObj.filterResultWithExclusion(sfObjs);
    flags=false(1,length(sfObjs));
    for i=1:length(sfObjs)
        try
            sfObjs{i}.UnderSpecDiagnostic='error';
            sfObjs{i}.OverspecDiagnostic='error';
        catch
            flags(i)=true;
        end
    end

    noGoList=[part2NoGo,sfObjs(flags)];

    if~isempty(noGoList)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setListObj(noGoList);
        ft.setSubBar(false);
        ft.setInformation(DAStudio.message('ModelAdvisor:hism:hisf_0011_action_info'));
    else
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(false);
        ft.setCheckText(DAStudio.message('ModelAdvisor:hism:hisf_0011_action_description'));
    end

    mdladvObj.setActionEnable(false);
    result.addItem(ft.emitContent);

end