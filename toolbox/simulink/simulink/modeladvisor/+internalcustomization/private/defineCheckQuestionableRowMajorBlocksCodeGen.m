


function rec=defineCheckQuestionableRowMajorBlocksCodeGen()

    rec=ModelAdvisor.Check('mathworks.codegen.RowMajorCodeGenSupport');

    rec.Title=DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_TitleTips');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleRowMajorSupport';
    rec.CallbackHandle=@ExecCheck;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='DetailStyle';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Embedded Coder';
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.SupportsEditTime=false;
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.Published=true;
end


function ExecCheck(system,CheckObj)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);




    Blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');

    FailedBlocks={};
    for i=2:length(Blocks)
        flag=isUnsupportedRowMajorBlock(Blocks{i});
        if~flag&&~(Stateflow.SLUtils.isChildOfStateflowBlock(Blocks{i}))
            FailedBlocks=[FailedBlocks,Blocks{i}];
        end
    end
    FailedBlocks=mdladvObj.filterResultWithExclusion(FailedBlocks);
    if isempty(FailedBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_Info'),...
        'Status',DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_pass'));
        mdladvObj.setCheckResultStatus(true);
    else
        ElementResults=Advisor.Utils.createResultDetailObjs(FailedBlocks,...
        'Description',DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_Info'),...
        'Status',DAStudio.message('ModelAdvisor:engine:QB_CG_RowMajor_warn'));
        mdladvObj.setCheckResultStatus(false);
    end
    CheckObj.setResultDetails(ElementResults);
end

function[bResult]=isUnsupportedRowMajorBlock(hBlock)
    oBlock=get_param(hBlock,'Object');
    bResult=oBlock.getBlockRowMajorSupport;
end
