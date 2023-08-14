
function rec=defineCheckQuestionableBlocksCodegen()

    rec=Simulink.MdlAdvisorCheck;













    rec.Title=DAStudio.message('ModelAdvisor:engine:QB_CG_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:QB_CG_TitleTips');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='MATitleCodeGenSupport';
    rec.RAWTitle='';
    rec.CallbackHandle=@ExecCheck;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink Coder';
    rec.GroupID='Simulink Coder';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.TitleID='mathworks.codegen.codeGenSupport';
    rec.LicenseName={'Real-Time_Workshop'};

end

function[ResultDescription,ResultHandles]=ExecCheck(system)

    ResultDescription={};
    ResultHandles={};


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);



    xlateTagPrefix='ModelAdvisor:engine:';
    confCommand='supportNotes_codeGenDefault';
    [bResultStatus,ResultDescription,ResultHandles]=...
    ModelAdvisor.Common.modelAdvisorCheck_QuestionableBlocksV2(system,...
    confCommand,xlateTagPrefix);

    if bResultStatus
        mdladvObj.setCheckResultStatus(true);
    end

end

