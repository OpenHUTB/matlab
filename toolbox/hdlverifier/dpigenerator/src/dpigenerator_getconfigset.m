function cfg=dpigenerator_getconfigset(modelName,IsTSVerifyPresentTop,IsTSVerifyPresentInMdlRef)




    cs=getActiveConfigSet(modelName);
    pp=cs.getPropOwner('DPIGenerateTestBench');

    cfg.DPIReportRunTimeError=strcmpi(pp.getProp('DPIReportRunTimeError'),'on');
    if cfg.DPIReportRunTimeError
        cfg.DPIRunTimeErrorSeverity=pp.getProp('DPIRunTimeErrorSeverity');
    end
    cfg.DPIGenerateTestBench=strcmpi(pp.getProp('DPIGenerateTestBench'),'on');
    cfg.DPICustomizeSystemVerilogCode=strcmpi(pp.getProp('DPICustomizeSystemVerilogCode'),'on');
    cfg.DPISystemVerilogTemplate=pp.getProp('DPISystemVerilogTemplate');
    cfg.DPITestPointAccessFcnInterface=pp.getProp('DPITestPointAccessFcnInterface');

    cfg.IsInterfaceEnabled=~strcmp(pp.getProp('DPIPortConnection'),'Port list');

    cfg.BlockReduction=cs.getProp('BlockReduction');
    cfg.OptimizeBlockIOStorage=cs.getProp('OptimizeBlockIOStorage');

    cfg.IsTSVerifyPresent=IsTSVerifyPresentTop||IsTSVerifyPresentInMdlRef;
    cfg.NeedToCpyTSVerifyCHeader=IsTSVerifyPresentTop||IsTSVerifyPresentInMdlRef;
    cfg.NeedToCpyTSVerifyCCode=IsTSVerifyPresentTop;


    cfg.IsExtendedObjhandleEnabled=IsTSVerifyPresentTop||IsTSVerifyPresentInMdlRef;



    cfg.SVStructEnabled=strcmpi(pp.getProp('DPICompositeDataType'),'structure');


    cfg.SVScalarizePortsEnabled=strcmpi(pp.getProp('DPIScalarizePorts'),'on');

    cfg.DPIComponentTemplateType=pp.getProp('DPIComponentTemplateType');


