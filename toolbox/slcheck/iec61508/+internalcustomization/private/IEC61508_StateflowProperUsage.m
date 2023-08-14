
function IEC61508_StateflowProperUsage




    rec=ModelAdvisor.Check('mathworks.iec61508.StateflowProperUsage');
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:SFProperUsageTitle');
    rec.setCallbackFcn(@ProperSFUsageCallback,'PostCompile','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:SFProperUsageTip');
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.Value=false;

    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508SFProperUsage';
    rec.setLicense({iec61508_license,'Stateflow'});
    rec.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);





    function ResultDescription=ProperSFUsageCallback(system)
        ResultDescription={};

        checkResultPass=true;
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);

        xlateTagPrefix='ModelAdvisor:iec61508:';
        ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'SFProperUsageTip']));

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_SFSignals(system,xlateTagPrefix);
        aliasResultDescription{1}.setSubBar(true);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_SFPortNames(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];

        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_SFDataObjects(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_SFBlocks(system,xlateTagPrefix);
        aliasResultDescription{1}.setSubBar(1);
        ResultDescription=[ResultDescription,aliasResultDescription];
        if~bResult
            checkResultPass=false;
        end



        checkPrefix='ModelAdvisor:iec61508:hisf_0002_';
        [info,results]=ModelAdvisor.Common.highInt_sf_0002_info(mdladvObj,system,checkPrefix);
        results{1}.setSubBar(1);
        ResultDescription=[ResultDescription,results];

        if(~info.bResults)
            checkResultPass=false;
        end
        checkPrefix='ModelAdvisor:iec61508:hisf_0011_';
        [results,info]=ModelAdvisor.Common.highInt_sf_0011_info(mdladvObj,checkPrefix,system);
        results{1}.setSubBar(1);
        ResultDescription=[ResultDescription,results];
        if(~info.bResults)
            checkResultPass=false;
        end

        xlateTagPrefix='ModelAdvisor:iec61508:';
        [bResultStatus,results]=ModelAdvisor.Common.modelAdvisorCheck_UniqueLocal(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,results];
        if(~bResultStatus)
            checkResultPass=false;
        end


        mdladvObj.setCheckResultStatus(checkResultPass);