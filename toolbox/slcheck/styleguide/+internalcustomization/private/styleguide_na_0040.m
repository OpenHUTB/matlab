
function styleguide_na_0040
    rec=ModelAdvisor.Check('mathworks.maab.na_0040');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0040_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0040';
    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:na_0040_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:na_0040_tip')];
    rec.setLicense({'SL_Verification_Validation'});
    rec.Value(true);
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:styleguide:na_0040_InpStatesNum');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='10';
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    inputParams=mdladvObj.getInputParameters;
    nestingThreshold=str2double(inputParams{1}.Value);
    if~isnumeric(nestingThreshold)||nestingThreshold<=0
        Errors.InputFieldName=DAStudio.message('ModelAdvisor:styleguide:na_0040_InpStatesNum');
        Errors.InputValue=inputParams{1}.Value;
        Errors.ShouldBe=DAStudio.message('ModelAdvisor:styleguide:InputPositiveInteger');
        ResultDescription=Advisor.Utils.reportInvalidInputParams(Errors);
        mdladvObj.setCheckErrorSeverity(1);
        mdladvObj.setCheckResultStatus(false);
        return;
    end

    [FailingStates,numVisStates]=checkAlgo(system);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na_0040_tip'));
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na_0040_TableCol1'),DAStudio.message('ModelAdvisor:styleguide:na_0040_TableCol2')});
    ft.setSubBar(0);

    if~isempty(FailingStates)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0040_Fail',num2str(nestingThreshold)));
        ft.setTableInfo([reshape(num2cell(FailingStates),length(FailingStates),1),reshape(num2cell(numVisStates),length(numVisStates),1)]);
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na_0040_RecAction'));
        mdladvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0040_Pass'));
        mdladvObj.setCheckResultStatus(true);
    end

    ResultDescription{end+1}=ft;

end


function[FailingStates,numVisStates]=checkAlgo(system)
    FailingStates=[];
    numVisStates=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;
    numStatesThreshold=str2double(inputParams{1}.Value);



    sfCharts=cell2mat(Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.Chart'}));


    if~isempty(sfCharts)
        sfBox=sfCharts.find('-isa','Stateflow.Box');
        sfContStates=sfCharts.find('-isa','Stateflow.State','IsSubchart',true,'-or','-isa','Stateflow.State','-function',@(x)numel(x.getChildren)~=0);
        sfContainers=[sfCharts;sfBox;sfContStates];


        sfContainers=mdladvObj.filterResultWithExclusion(sfContainers);

        Flags=false(1,length(sfContainers));
        numVisStates=zeros(length(sfContainers),1);
        for i=1:length(sfContainers)
            states=setdiff(sfContainers(i).find('-isa','Stateflow.State','-or','-isa','Stateflow.AtomicSubchart','-or','-isa','Stateflow.ActionState','-or','-isa','Stateflow.SimulinkBasedState'),sfContainers(i));
            numVisStates(i)=sum(arrayfun(@(x)isVisibleState(x,sfContainers(i)),states));
            if numVisStates(i)>numStatesThreshold
                Flags(i)=true;
            end
        end
        FailingStates=sfContainers(Flags);
        numVisStates=numVisStates(Flags);
    end
end


function bIsVisible=isVisibleState(state,topContainer)
    bIsVisible=false;
    while state~=topContainer
        state=state.getParent;
        if~(isa(state,'Stateflow.State')||isa(state,'Stateflow.Box')||isa(state,'Stateflow.Chart'))||(isa(state,'Stateflow.State')&&state.IsSubchart&&state~=topContainer)
            return;
        end
    end
    bIsVisible=true;
end





