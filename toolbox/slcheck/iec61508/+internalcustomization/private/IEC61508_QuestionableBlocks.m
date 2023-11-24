
function rec=IEC61508_QuestionableBlocks

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:QuestionableBlocksTitle');
    rec.TitleID='mathworks.iec61508.QuestionableBlks';
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:QuestionableBlocksTip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@QuestionableBlocksCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.VisibleInProductList=false;
    rec.Group=iec61508_group;
    rec.LicenseName={iec61508_license};
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508QuestionableBlocks';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;




    function[ResultDescription,ResultHandles]=QuestionableBlocksCallback(system)

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(true);

        xlateTagPrefix='ModelAdvisor:iec61508:';
        [bResultStatus,ResultDescription,ResultHandles]=ModelAdvisor.Common.modelAdvisorCheck_QuestionableBlocks(system,xlateTagPrefix);
        ResultDescription{end}.setSubBar(false);
        mdladvObj.setCheckResultStatus(bResultStatus);
