
function rec=IEC61508_UnconnectedObjects

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:UnconnectedObjectsTitle');
    rec.TitleID='mathworks.iec61508.UnconnectedObjects';
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:UnconnectedObjectsCheckDesc');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@UnconnectedObjectsCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=iec61508_group;
    rec.LicenseName={iec61508_license};
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508UnconnectedObjects';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;



    function ResultDescription=UnconnectedObjectsCallback(system)

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);

        xlateTagPrefix='ModelAdvisor:iec61508:';

        [bResult,ResultDescription]=...
        ModelAdvisor.Common.modelAdvisorCheck_UnconnectedObjects(system,xlateTagPrefix);


        mdladvObj.setCheckResultStatus(bResult);


