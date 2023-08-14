


function rec=defineCheckRowMajorAlgorithm()

    rec=ModelAdvisor.Check('mathworks.codegen.UseRowMajorAlgorithm');

    rec.Title=DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_TitleTips');
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='MATitleRowMajorAlgorithm';
    rec.CallbackHandle=@ExecCheck;
    rec.CallbackContext='None';
    rec.CallbackStyle='DetailStyle';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.Published=true;
end


function ExecCheck(system,CheckObj)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);



    SumBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','Sum');
    ProductBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','Product');

    FailedBlocks={};
    for i=1:length(SumBlocks)
        flag=IsCollapsingOp(SumBlocks{i});
        if flag
            FailedBlocks=[FailedBlocks,SumBlocks{i}];
        end
    end
    for i=1:length(ProductBlocks)
        flag=IsCollapsingOp(ProductBlocks{i});
        if flag
            FailedBlocks=[FailedBlocks,ProductBlocks{i}];
        end
    end



    LookupNDDirectBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','LookupNDDirect');
    LookupNDBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','Lookup_n-D');
    InterpBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','Interpolation_n-D');

    for i=1:length(LookupNDDirectBlocks)
        FailedBlocks=[FailedBlocks,LookupNDDirectBlocks{i}];
    end
    for i=1:length(LookupNDBlocks)
        FailedBlocks=[FailedBlocks,LookupNDBlocks{i}];
    end
    for i=1:length(InterpBlocks)
        FailedBlocks=[FailedBlocks,InterpBlocks{i}];
    end

    FailedBlocks=mdladvObj.filterResultWithExclusion(FailedBlocks);

    failed1=false;
    failed2=false;
    if isempty(strfind(getfullname(system),'/'))
        arraylayout=get_param(system,'ArrayLayout');
        rowmajorAlgo=get_param(system,'UseRowMajorAlgorithm');
        failed1=(strcmp(arraylayout,'Column-major')&&strcmp(rowmajorAlgo,'on'));
        failed2=(strcmp(arraylayout,'Row-major')&&strcmp(rowmajorAlgo,'off'));
    end
    if(failed1||failed2)&&~isempty(FailedBlocks)
        if(failed2)
            ElementResults=Advisor.Utils.createResultDetailObjs(FailedBlocks,...
            'Status',DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_warn'),...
            'RecAction',DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_warnfix'));
        else
            if(failed1)
                ElementResults=Advisor.Utils.createResultDetailObjs(FailedBlocks,...
                'Status',DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_warn'),...
                'RecAction',DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_warnfix_deselect'));
            end
        end
        mdladvObj.setCheckResultStatus(false);
    else
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Status',DAStudio.message('ModelAdvisor:engine:UseRowMajorAlgorithm_pass'));
        mdladvObj.setCheckResultStatus(true);
    end
    CheckObj.setResultDetails([CheckObj.ResultDetails,ElementResults]);
end

function[bResult]=IsCollapsingOp(hBlock)
    bResult=false;
    numInputs=get_param(hBlock,'Inputs');
    if(strcmp(numInputs,'+')||strcmp(numInputs,'-')||strcmp(numInputs,'*')||strcmp(numInputs,'/'))
        collapseMode=get_param(hBlock,'CollapseMode');
        if(strcmp(collapseMode,'All dimensions'))
            bResult=true;
        end
    end
end
