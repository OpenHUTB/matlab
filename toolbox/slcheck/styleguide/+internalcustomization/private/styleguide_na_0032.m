function styleguide_na_0032




    rec=ModelAdvisor.Check('mathworks.maab.na_0032');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0032_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0032';
    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na_0032_tip');

    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;

    rec.setLicense({styleguide_license});
    rec.Value=false;

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

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FailingBlocks=(checkAlgo(system));
    [rows,~]=size(FailingBlocks);

    for i=1:rows
        FailingBlocks{i,2}=DAStudio.message(['ModelAdvisor:styleguide:na_0032_Issue',num2str(FailingBlocks{i,2})]);
    end

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na_0032_tip'));
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na_0032_TableCol1'),DAStudio.message('ModelAdvisor:styleguide:na_0032_TableCol2')});

    if~isempty(FailingBlocks)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0032_warn'));
        ft.setTableInfo(FailingBlocks);
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na_0032_RecAction'));
        mdladvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0032_pass'));
        mdladvObj.setCheckResultStatus(true);
    end

    ResultDescription{end+1}=ft;

end


function FailingObjs=checkAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;



    MergeBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Merge');

    MergeBlocks=mdladvObj.filterResultWithExclusion(MergeBlocks);

    Flag=false(1,length(MergeBlocks));
    Issues=zeros(1,length(MergeBlocks));
    for i=1:length(MergeBlocks)
        [Flag(i),Issues(i)]=isBadMergeBlockConstruct(MergeBlocks{i});
    end

    FailingObjs=[reshape(MergeBlocks(Flag),length(MergeBlocks(Flag)),1),num2cell(reshape(Issues(Flag),length(MergeBlocks(Flag)),1))];
end


function[bResult,issueType]=isBadMergeBlockConstruct(hBlock)
    oBlock=get_param(hBlock,'Object');

    bResult=false;
    issueType=0;


    ip=get_param(oBlock.PortHandles.Inport,'Object');



    if numel(ip)<=1
        return;
    end


    if strcmp(oBlock.AllowUnequalInputPortWidths,'on')&&~all(cellfun(@(x)isequal(x.CompiledPortDimensions,ip{1}.CompiledPortDimensions),ip))
        bResult=true;
        issueType=1;
    else






        firstSource=getBoundedSource(ip{1});

        for idx=2:length(ip)
            sourceH=getBoundedSource(ip{idx});
            if~isempty(sourceH)&&ishandle(sourceH(1))
                sigH1=get_param(sourceH(1),'SignalHierarchy');
                if~isempty(firstSource)&&~isequal(sigH1,get_param(firstSource(1),'SignalHierarchy'))
                    bResult=true;
                    issueType=2;
                    return;
                end
            end
        end

    end
end

function bSrc=getBoundedSource(block)
    try
        bSrc=block.getBoundedSrc;
    catch
        bSrc=[];
    end
end
