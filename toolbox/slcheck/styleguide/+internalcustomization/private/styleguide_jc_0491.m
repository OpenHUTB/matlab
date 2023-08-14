function styleguide_jc_0491
    rec=ModelAdvisor.Check('mathworks.maab.jc_0491');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc_0491_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0491';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:styleguide:jc_0491',@CheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc_0491_tip');
    rec.Value=true;

    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;

    rec.setLicense({styleguide_license,'Stateflow'});

    rec.setInputParametersLayoutGrid([1,4]);


    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end


function[resultData]=CheckAlgo(system)

    resultData=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    sfCharts=Advisor.Utils.Stateflow.sfFindSys...
    (system,...
    inputParams{1}.Value,...
    inputParams{2}.Value,...
    {'-isa','Stateflow.Chart'});

    sfCharts=mdladvObj.filterResultWithExclusion(sfCharts);

    for c1=1:numel(sfCharts)
        sfState=sfCharts{c1}.find('-isa','Stateflow.State');



        if isempty(sfState)
            failedSFTData=checkTransitionRule1(sfCharts{c1});
            resultData=[resultData,failedSFTData];

        else
            sfLocalData=sfCharts{c1}.find('-isa','Stateflow.Data',...
            'Scope','Local',...
            '-depth',1);
            for c2=1:numel(sfState)
                failedSFTData=checkTransitionRule1(sfState(c2));
                resultData=[resultData,failedSFTData];
                failedSFTData=checkTransitionRule2(sfState(c2),sfLocalData);
                resultData=[resultData,failedSFTData];

            end
        end
    end

end



function failedSFTData=checkTransitionRule1(sfObj)









    failedSFTData=[];

    if isa(sfObj,'Stateflow.Chart')
        sfOutputData=sfObj.find('-isa','Stateflow.Data','scope','output');
        actionLang=sfObj.ActionLanguage;
    else
        sfChart=sfObj.Chart;
        sfOutputData=sfChart.find('-isa','Stateflow.Data','scope','output');
        actionLang=sfChart.ActionLanguage;
    end

    sfJunctions=sfObj.find('-isa','Stateflow.Junction');
    sfTransitions=sfObj.find('-isa','Stateflow.Transition');



    if isempty(sfJunctions)||...
        isempty(sfTransitions)||...
        isempty(sfOutputData)
        return;
    end
    sfOutputDataName=arrayfun(@(x){x.name},sfOutputData)';
    sfJunctionMap=containers.Map(arrayfun(@(x)x.Id,sfJunctions),1:numel(sfJunctions));
    sfJunctionMapInv=containers.Map(1:numel(sfJunctions),arrayfun(@(x)x.Id,sfJunctions));


    adjM=Advisor.Utils.Graph.getAdjMatFrmTransition(sfJunctionMap,sfTransitions);


    [~,cycles]=Advisor.Utils.Graph.findCycles(adjM);

    for c2=1:numel(cycles)


        loopCounter=Advisor.Utils.Stateflow.getLoopCountersInTransitions(cycles{c2},...
        sfJunctionMapInv);


        if isempty(loopCounter)
            continue;
        end

        for c3=1:numel(loopCounter)



            varIndex=ismember(sfOutputDataName,loopCounter(c3));

            if any(varIndex)

                RDObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(RDObj,'SID',sfOutputData(varIndex));
                RDObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:jc_0491_recAction_transition');
                RDObj.Status=DAStudio.message('ModelAdvisor:styleguide:jc_0491_warn_transition');
                failedSFTData=[failedSFTData,RDObj];

            end
        end
    end

end

function faileSFData=checkTransitionRule2(sfObj,ChartData)










    faileSFData=[];




    if~isa(sfObj.getParent,'Stateflow.Chart')
        return;
    end

    sfData=[ChartData;sfObj.find('-isa','Stateflow.Data','scope','Local')];


    sfDataNames=arrayfun(@(x)x.Name,sfData,'UniformOutput',false);


    sfStates=sfObj.find('-isa','Stateflow.State');

    sfUsedDataNames=[];

    for count1=1:numel(sfStates)


        dataNames=Advisor.Utils.Stateflow.getDataUsedInSFObj(sfStates(count1));

        if isempty(dataNames)
            continue;
        end

        sfUsedDataNames=[sfUsedDataNames;dataNames(:)];
    end

    if isempty(sfUsedDataNames)
        return;
    end

    for count=1:numel(sfDataNames)




        if numel(find(contains(sfUsedDataNames,sfDataNames(count))))>1

            RDObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(RDObj,'SID',sfData(count));
            RDObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:jc_0491_recAction_state');
            RDObj.Status=DAStudio.message('ModelAdvisor:styleguide:jc_0491_warn_state');
            faileSFData=[faileSFData,RDObj];

        end
    end
end

