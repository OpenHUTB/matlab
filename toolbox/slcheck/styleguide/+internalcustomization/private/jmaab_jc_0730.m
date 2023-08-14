function jmaab_jc_0730

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0730');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0730_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0730';
    rec.setCallbackFcn(@CheckCallBackFcn,'none','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0730_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function results=CheckCallBackFcn(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultData=checkAlgo(system);
    [bResultStatus,results]=Advisor.Utils.getTwoColumnReport...
    ('ModelAdvisor:jmaab:jc_0730',resultData.failedCharts);
    if resultData.noChartsFound
        results.setSubResultStatusText(DAStudio.message...
        ('ModelAdvisor:jmaab:jc_0730_no_stateflow_chart'));
    end
    mdlAdvObj.setCheckResultStatus(bResultStatus);
end


function[resultData]=checkAlgo(system)
    resultData.failedBlocks=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    sfCharts=Advisor.Utils.Stateflow.sfFindSys...
    (system,...
    inputParams{1}.Value,...
    inputParams{2}.Value,...
    {'-isa','Stateflow.Chart'});
    if~isempty(sfCharts)
        resultData.noChartsFound=false;
        sfCharts=mdladvObj.filterResultWithExclusion(sfCharts);
        failedChartElements=[];
        for count=1:length(sfCharts)
            sfStates=sfCharts{count}.find('-isa','Stateflow.State',...
            '-or','-isa','Stateflow.AtomicSubchart',...
            '-or','-isa','Stateflow.ActionState',...
            '-or','-isa','Stateflow.SimulinkBasedState');
            failedChartElements=[failedChartElements;
            statesWithSameName(sfCharts{count},sfStates)];
        end
        resultData.noChartsFound=false;
        resultData.failedCharts=failedChartElements;
    else
        resultData.noChartsFound=true;
        resultData.failedCharts=[];
    end

end


function failedState=statesWithSameName(sfChart,sfStates)
    stateName=arrayfun(@(x)x.Name,sfStates,'UniformOutput',false);
    listOfLinks=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),sfStates,'UniformOutput',false);
    [uniqueNames,~,index]=unique(stateName,'stable');
    countOfNames=cellfun(@(x)sum(ismember(stateName,x)),uniqueNames,'UniformOutput',false);
    repeatedVal=find([countOfNames{:}]>1);
    failedState=[];
    for count=1:length(repeatedVal)
        sfIndex=index==repeatedVal(count);
        failedState=[failedState;
        {Advisor.Utils.Simulink.getObjHyperLink(sfChart),...
        Advisor.Utils.getTableOfConflicts(listOfLinks(sfIndex))}];
    end
end

