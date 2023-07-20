


function rec=defineCheckRowMajorUnsetSFunction()

    rec=ModelAdvisor.Check('mathworks.codegen.RowMajorUnsetSFunction');

    rec.Title=DAStudio.message('ModelAdvisor:engine:RowMajorUnsetSFunction_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:RowMajorUnsetSFunction_TitleTips');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleRowMajorUnsetSFunction';
    rec.CallbackHandle=@ExecCheck;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='DetailStyle';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group='Embedded Coder';
    rec.SupportExclusion=true;
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.Published=true;
end


function ExecCheck(system,CheckObj)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);




    Blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',' all','BlockType','S-Function');

    FailedBlocks={};
    for i=1:length(Blocks)
        flag=isUnsetSFunction(Blocks{i});
        if flag
            FailedBlocks=[FailedBlocks,Blocks{i}];
        end
    end
    FailedBlocks=mdladvObj.filterResultWithExclusion(FailedBlocks);
    ElementResults=Advisor.Utils.createResultDetailObjs('',...
    'IsInformer',true,...
    'Description',DAStudio.message('ModelAdvisor:engine:RowMajorUnsetSFunction_Info'));
    CheckObj.setResultDetails([CheckObj.ResultDetails,ElementResults]);
    if~isempty(FailedBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs(FailedBlocks,...
        'Status',DAStudio.message('ModelAdvisor:engine:RowMajorUnsetSFunction_warn'));

        mdladvObj.setCheckResultStatus(false);
    else
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Status',DAStudio.message('ModelAdvisor:engine:RowMajorUnsetSFunction_pass'));
        mdladvObj.setCheckResultStatus(true);
    end
    CheckObj.setResultDetails([CheckObj.ResultDetails,ElementResults]);
end

function[bResult]=isUnsetSFunction(hBlock)
    oBlock=get_param(hBlock,'Object');
    bResult=oBlock.getIsSFunctionUnset;
end
