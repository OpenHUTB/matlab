function hisf_0001

    rec=getNewCheckObject('mathworks.hism.hisf_0001',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisf_0001_inputParam');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={'Classic','Mealy','Moore'};
    inputParamList{end}.Visible=false;
    inputParamList{end}.setRowSpan([2,2]);
    inputParamList{end}.setColSpan([1,2]);

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)






    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    defaultCharttype=inputParams{3}.Value;


    allCharts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    allCharts=mdladvObj.filterResultWithExclusion(allCharts);

    for i=1:numel(allCharts)
        if~strcmpi(allCharts{i}.StateMachineType,defaultCharttype)
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'Block',allCharts{i},'Parameter','StateMachineType','CurrentValue',allCharts{i}.StateMachineType,'RecommendedValue',defaultCharttype);
            violations=[violations;tempObj];%#ok<AGROW>
        end
    end
end

