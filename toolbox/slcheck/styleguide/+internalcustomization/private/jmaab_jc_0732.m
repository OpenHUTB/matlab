function jmaab_jc_0732

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0732');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0732_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0732';
    rec.setCallbackFcn(@CheckCallBackFcn,'none','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0732_tip');
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


function ElementResults=CheckCallBackFcn(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultData=checkAlgo(system);
    [bResultStatus,ElementResults]=Advisor.Utils.getTwoColumnReport...
    ('ModelAdvisor:jmaab:jc_0732',resultData.failedCharts);
    if resultData.noChartsFound
        ElementResults.setSubResultStatusText(DAStudio.message...
        ('ModelAdvisor:jmaab:jc_0732_no_stateflow_chart'));
    end
    mdlAdvObj.setCheckResultStatus(bResultStatus);
end


function[resultData]=checkAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    allCharts=Advisor.Utils.Stateflow...
    .sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,...
    {'-isa','Stateflow.Chart'});
    if~isempty(allCharts)
        allCharts=mdladvObj.filterResultWithExclusion(allCharts);
        failedChartElements=[];
        for c1=1:length(allCharts)
            failedChartElements=[failedChartElements;...
            checkForCommonDataAndState(allCharts{c1})];
        end
        resultData.noChartsFound=false;
        resultData.failedCharts=failedChartElements;
    else
        resultData.noChartsFound=true;
        resultData.failedCharts=[];
    end
end



function failedData=checkForCommonDataAndState(chart)













    failedData=[];

    sfStates=chart.find('-isa','Stateflow.State',...
    '-or','-isa','Stateflow.AtomicSubchart',...
    '-or','-isa','Stateflow.ActionState',...
    '-or','-isa','Stateflow.SimulinkBasedState');

    sfData=chart.find('-isa','Stateflow.Data');
    sfEvents=chart.find('-isa','Stateflow.Event');

    if isempty(sfStates)&&isempty(sfData)&&isempty(sfEvents)
        return
    end



    StateNames=arrayfun(@(x)x.Name,sfStates,'UniformOutput',false);



    VariableNames=arrayfun(@(x)x.Name,sfData,'UniformOutput',false);


    EventNames=arrayfun(@(x)x.Name,sfEvents,'UniformOutput',false);










    combinedNames={[StateNames;VariableNames;EventNames]};








    for idx=1:numel(combinedNames)
        uniqueNames=unique(combinedNames{idx},'stable');
        countOfNames=cellfun(@(x)sum(ismember(combinedNames{idx},x)),uniqueNames,'UniformOutput',false);
        repeatedIndex=find([countOfNames{:}]>2);

        for c1=1:length(repeatedIndex)
            commonData=sfData(ismember(VariableNames,uniqueNames(repeatedIndex(c1))));
            commonState=sfStates(ismember(StateNames,uniqueNames(repeatedIndex(c1))));
            commonEvent=sfEvents(ismember(EventNames,uniqueNames(repeatedIndex(c1))));
            if isempty(commonData)||isempty(commonState)||isempty(commonEvent)
                continue;
            end
            sfDataLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonData,'UniformOutput',false);
            sfStateLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonState,'UniformOutput',false);
            sfEventLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonEvent,'UniformOutput',false);
            failedData=[failedData;...
            {chart.Path,...
            Advisor.Utils.getTableOfConflicts(sfStateLink)...
            ,Advisor.Utils.getTableOfConflicts(sfDataLink)...
            ,Advisor.Utils.getTableOfConflicts(sfEventLink)}];

            StateNames=StateNames(~cellfun(@(x)strcmp(x,uniqueNames(repeatedIndex(c1))),StateNames));
            VariableNames=VariableNames(~cellfun(@(x)strcmp(x,uniqueNames(repeatedIndex(c1))),VariableNames));
            EventNames=EventNames(~cellfun(@(x)strcmp(x,uniqueNames(repeatedIndex(c1))),EventNames));

            sfStates=sfStates(~arrayfun(@(x)strcmp(x.Name,uniqueNames(repeatedIndex(c1))),sfStates));
            sfData=sfData(~arrayfun(@(x)strcmp(x.Name,uniqueNames(repeatedIndex(c1))),sfData));
            sfEvents=sfEvents(~arrayfun(@(x)strcmp(x.Name,uniqueNames(repeatedIndex(c1))),sfEvents));
        end
    end


    names={[StateNames;VariableNames],[StateNames;EventNames],[VariableNames;EventNames]};

    for idx=1:numel(names)
        uniqueNames=unique(names{idx},'stable');
        countOfNames=cellfun(@(x)sum(ismember(names{idx},x)),uniqueNames,'UniformOutput',false);
        repeatedIndex=find([countOfNames{:}]>1);

        for c1=1:length(repeatedIndex)
            commonData=sfData(ismember(VariableNames,uniqueNames(repeatedIndex(c1))));

            if idx==1&&~isempty(commonData)
                commonState=sfStates(ismember(StateNames,uniqueNames(repeatedIndex(c1))));
                if~isempty(commonState)
                    sfDataLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonData,'UniformOutput',false);
                    sfStateLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonState,'UniformOutput',false);
                    failedData=[failedData;...
                    {chart.Path,...
                    Advisor.Utils.getTableOfConflicts(sfStateLink)...
                    ,Advisor.Utils.getTableOfConflicts(sfDataLink)...
                    ,Advisor.Utils.getTableOfConflicts(' ')}];
                end
            end

            commonEvent=sfEvents(ismember(EventNames,uniqueNames(repeatedIndex(c1))));

            if idx==2&&~isempty(commonEvent)
                commonState=sfStates(ismember(StateNames,uniqueNames(repeatedIndex(c1))));
                if~isempty(commonState)
                    sfEventLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonEvent,'UniformOutput',false);
                    sfStateLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonState,'UniformOutput',false);
                    failedData=[failedData;...
                    {chart.Path,...
                    Advisor.Utils.getTableOfConflicts(sfStateLink)...
                    ,Advisor.Utils.getTableOfConflicts(' ')...
                    ,Advisor.Utils.getTableOfConflicts(sfEventLink)}];
                end
            end

            commonEvent=sfEvents(ismember(EventNames,uniqueNames(repeatedIndex(c1))));

            if idx==3&&~isempty(commonEvent)
                commonData=sfData(ismember(VariableNames,uniqueNames(repeatedIndex(c1))));
                if~isempty(commonData)
                    sfEventLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonEvent,'UniformOutput',false);
                    sfDataLink=arrayfun(@(x)Advisor.Utils.Simulink.getObjHyperLink(x),commonData,'UniformOutput',false);
                    failedData=[failedData;...
                    {chart.Path,...
                    Advisor.Utils.getTableOfConflicts(' ')...
                    ,Advisor.Utils.getTableOfConflicts(sfDataLink)...
                    ,Advisor.Utils.getTableOfConflicts(sfEventLink)}];
                end
            end
        end
    end
end

function MAText=getTableText(obj)











    link=Advisor.Utils.Simulink.getObjHyperLink(obj);
    MAText=Advisor.Text();
    if isa(obj,'Stateflow.Data')
        MAText.Content=[link.emitHTML,'{Stateflow.Data}'];
    else
        MAText.Content=[link.emitHTML,'{Stateflow.State}'];
    end
end
