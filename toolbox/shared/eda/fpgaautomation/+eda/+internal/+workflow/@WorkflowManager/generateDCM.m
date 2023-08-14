function generateDCM(h)




    xilinxObj=h.mXilinxAIObj;
    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;

    if~userParam.genClockModule
        return;
    end

    hdldisp(['Generating clock module for ',hdlcData.dutName]);
    disp(' ');






    if isempty(hdlcData.dut.clock)
        error(message('EDALink:WorkflowManager:generateDCM:noclock'));
    end

    if hdlcData.clockinputs>1
        error(message('EDALink:WorkflowManager:generateDCM:MultiClock'));
    end

    if strcmpi(hdlcData.target_language,'VHDL')&&...
        ~(hdlcData.filter_input_type_std_logic&&hdlcData.filter_output_type_std_logic)
        error(message('EDALink:WorkflowManager:generateDCM:StdLogicPort'));
    end










    DUT=h.createDUTComp;


    params=struct();


    params.Family=userParam.projectTarget.family;
    params.Device=userParam.projectTarget.device;
    params.Package=userParam.projectTarget.package;
    params.Speed=userParam.projectTarget.speed;


    params.HDLLanguage=hdlcData.target_language;
    params.OutputDirectory=hdlcData.codegenDir;

    params.ModuleName=[hdlcData.dutName,tdkParam.clkModuleName];


    params.InputClock.Period=userParam.clkinPeriod;


    params.OutputClocks{1}.Name='clkout';
    params.OutputClocks{1}.Period=userParam.clkoutPeriod;



    clkModule=xilinxObj.generateClock(params);
    for ii=1:length(clkModule.Design.Files)
        f=[hdlcData.codegenDir,filesep,clkModule.Design.Files{ii}];
        msg=['Generating HDL file for: ',hdlgetfilelink(f)];
        hdldisp(msg);
    end


    DCM=h.createDCMComp(clkModule);
    TOP=h.createTopComp(DUT,DCM);
    TOP.gBuild;
    TOP.gUnify;
    TOP.hdlcodeinit;
    TOP.hdlCodeGen(hdlcData.hdlPropSet);
    ucfFile=h.writeClockPeriodUCF;

    h.mWorkflowInfo.tdkParam.tdkFiles=[tdkParam.tdkFiles,TOP.HDLFiles,{ucfFile}];

