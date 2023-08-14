

function rec=IEC61508_ModelVersionInfo

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:ModelVersionInfoTitle');
    rec.TitleID='mathworks.iec61508.MdlVersionInfo';
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:ModelVersionInfoTip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@ModelVersionInfoCallback;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group=iec61508_group;
    rec.LicenseName={iec61508_license};
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508ModelVersionInfo';
end





function result=ModelVersionInfoCallback(system)
    xlateTagPrefix='ModelAdvisor:iec61508:';

    [bResult,result]=ModelAdvisor.Common.modelAdvisorCheck_ModelVersionInfo(system,xlateTagPrefix);


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(bResult);
end
