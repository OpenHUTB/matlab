
function rec=DO178B_ModelChecksum



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:do178b:ModelChecksumTitle');
    rec.TitleID='mathworks.do178.MdlChecksum';
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:ModelChecksumTip');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.do178b';
    rec.CSHParameters.TopicID='ModelChecksumTitle';
    rec.CallbackHandle=@ModelChecksumCallback;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group=do178b_group;
    rec.LicenseName={do178b_license};
end




function result=ModelChecksumCallback(system)
    xlateTagPrefix='ModelAdvisor:do178b:';

    [bResult,result]=ModelAdvisor.Common.modelAdvisorCheck_ModelVersionInfo(system,xlateTagPrefix);


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(bResult);
end

