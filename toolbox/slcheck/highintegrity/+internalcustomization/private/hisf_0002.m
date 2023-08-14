function hisf_0002

    rec=getNewCheckObject('mathworks.hism.hisf_0002',false,@hCheckAlgo,'None');

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

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@hCheckAction);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:hism:hisf_0002_action_tip');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end



function violations=hCheckAlgo(system)

    violations=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    charts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    charts=mdlAdvObj.filterResultWithExclusion(charts);


    for i=1:length(charts)

        if~charts{i}.UserSpecifiedStateTransitionExecutionOrder
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',charts{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisf_0002_rec_action1');
            violations=[violations,tempFailObj];%#ok<AGROW>
        end

    end
end


function results=hCheckAction(taskobj)

    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);

    inputParams=mdladvObj.getInputParameters;

    charts=Advisor.Utils.Stateflow.sfFindSys(mdladvObj.System,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    charts=mdladvObj.filterResultWithExclusion(charts);

    flag=false(1,numel(charts));
    for i=1:length(charts)
        if~charts{i}.UserSpecifiedStateTransitionExecutionOrder
            charts{i}.UserSpecifiedStateTransitionExecutionOrder=1;
            flag(i)=true;
        end

    end

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setCheckText({DAStudio.message('ModelAdvisor:hism:hisf_0002_action_description')});
    ft.setListObj(charts(flag));
    results=ft;
end

