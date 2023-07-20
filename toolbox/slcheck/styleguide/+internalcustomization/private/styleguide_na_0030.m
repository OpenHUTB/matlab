function styleguide_na_0030




    rec=ModelAdvisor.Check('mathworks.maab.na_0030');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0030_title');
    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na_0030_tip');
    rec.setLicense({styleguide_license});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0030';
    rec.Value=false;

    rec.SupportExclusion=false;
    rec.SupportLibrary=false;
    rec.SupportHighlighting=true;

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:styleguide:NamingConventions');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Value='MAB';
    inputParamList{end}.Entries={'MAB','Custom'};
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:styleguide:RegexpCheckInvalidChars');
    inputParamList{end}.Type='String';

    inputParamList{end}.Value=ModelAdvisor.Common.getDefaultRegularExpression_jc_0201;
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=false;


    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';


    rec.setInputParametersLayoutGrid([3,4]);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.regexp_MAAB_InputParamCB);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    bResultStatus=true;

    xlateTagPrefix='ModelAdvisor:styleguide:';

    [FailingObjs]=checkAlgo(system);


    ft=ModelAdvisor.FormatTemplate('TableTemplate');


    ft.setColTitles({DAStudio.message([xlateTagPrefix,'na_0030_TableCol1']),DAStudio.message([xlateTagPrefix,'na_0030_TableCol2'])});
    if~isempty(FailingObjs)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'na_0030_Fail']));
        ft.setTableInfo(struct2cell(FailingObjs)');
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'na_0030_RecAction']));
        bResultStatus=bResultStatus&&false;
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'na_0030_Pass']));
        bResultStatus=bResultStatus&&true;
    end
    ft.setSubBar(0);
    ResultDescription{end+1}=ft;

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(bResultStatus);
end


function FailingObjs=checkAlgo(system)
    FailingObjs=[];



    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    inputParams=mdladvObj.getInputParameters;
    rStr=inputParams{2}.Value;



    AllSignals=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{3}.Value,'LookUnderMasks',inputParams{4}.Value,'FindAll','on','type','line');

    AllSignals=get_param(AllSignals,'Object');




    if~iscell(AllSignals)
        AllSignals={AllSignals};
    end

    AllBus=AllSignals(cellfun(@(x)ishandle(x.SrcPortHandle)&&~strcmp(get_param(x.SrcPortHandle,'CompiledBusType'),'NOT_BUS'),AllSignals));




    [~,indices]=unique(cellfun(@(x)x.SrcPortHandle,AllBus));
    AllBus=AllBus(indices);


    AllBusNames=cellfun(@(x)getfield(get_param(x.SrcPortHandle,'SignalHierarchy'),'SignalName'),AllBus,'UniformOutput',false);
    indices=find(cellfun(@(x)~isempty(x),AllBusNames));
    AllBusNames=AllBusNames(indices);


    for i=1:length(AllBusNames)
        [isValid,position]=Advisor.Utils.Simulink.isNameValid(num2str(AllBusNames{i}),rStr);

        if~isValid
            tempObj.Name=Advisor.Utils.Simulink.highlightWrongCharacter(num2str(AllBusNames{i}),position);
            tempObj.Block=AllBus{indices(i)}.Handle;
            FailingObjs=[FailingObjs;tempObj];%#ok<AGROW>
        end
    end

end




