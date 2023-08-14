










function misraCheckAssignmentBlocks

    checkId='mathworks.misra.AssignmentBlocks';

    act=ModelAdvisor.Action;
    act.Name=TEXT('Action_Name');
    act.Description=TEXT('Action_Description',getParameterString());
    act.setCallbackFcn(@checkAction);

    rec=ModelAdvisor.internal.EdittimeCheck(checkId);
    rec.Title=TEXT('Title');
    rec.TitleTips=TEXT('TitleTips',getParameterString());
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.AssignmentBlocks';
    rec.SupportsEditTime=true;
    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end

function string=TEXT(id,varargin)
    prefix='RTW:misra:AssignmentBlocks_';
    messageId=[prefix,id];
    string=DAStudio.message(messageId,varargin{:});
end


function result=checkAction(~)
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    result=ModelAdvisor.FormatTemplate('TableTemplate');
    paramString=DAStudio.message('Simulink:blkprm_prompts:DiagOptionNoAll');
    result.setCheckText(DAStudio.message('RTW:misra:AssignmentBlocks_ActionResultText',paramString));

    result.setColTitles({...
    DAStudio.message('RTW:misra:AssignmentBlocks_ActionColumn1'),...
    DAStudio.message('RTW:misra:AssignmentBlocks_ActionColumn2'),...
    DAStudio.message('RTW:misra:AssignmentBlocks_ActionColumn3')});
    checkResult=mdladvObj.getCheckResult(mdladvObj.ActiveCheck.ID);
    tableInfo=checkResult{1}.TableInfo;
    tableInfo(:,end-1)=[];
    for blockIndex=1:size(tableInfo,1)
        thisBlock=tableInfo{blockIndex,1};
        recommendedValue=tableInfo{blockIndex,3};
        set_param(thisBlock,'DiagnosticForDimensions',recommendedValue);
    end
    result.setTableInfo(tableInfo);
end

function string=getParameterString()
    string=DAStudio.message('Simulink:blkprm_prompts:DiagOptionNoAll');
    if string(end)==':'
        string=string(1:end-1);
    end
end

