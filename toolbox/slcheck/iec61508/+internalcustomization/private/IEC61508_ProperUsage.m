
function rec=IEC61508_ProperUsage



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:ProperUsageTitle');
    rec.TitleID='mathworks.iec61508.ProperUsage';
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:ProperUsageTip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@ProperUsageCallback;
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
    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508ProperUsage';





    function[ResultDescription]=ProperUsageCallback(system)
        ResultDescription={};

        checkResultPass=true;

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);

        xlateTagPrefix='ModelAdvisor:iec61508:';

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_absBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_relopBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_whileBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_forBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];

        if~bResult
            checkResultPass=false;
        end


        mdladvObj.setCheckResultStatus(checkResultPass);
