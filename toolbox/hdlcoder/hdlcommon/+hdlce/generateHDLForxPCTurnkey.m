function generateHDLForxPCTurnkey(refMdlName,targetMappingInfo)



    workflow='Simulink Real-Time FPGA I/O';

    hdlset_param(refMdlName,'HDLSubsystem',refMdlName);
    hdlset_param(refMdlName,'TargetDir',fullfile('hdl_prj','hdlsrc'));

    hDI=downstream.integration('Model',refMdlName,'cmdDisplay',true);

    hDI.set('Workflow',workflow);
    hDI.set('Board',targetMappingInfo.hdlBoardName);


    assert(strcmp(targetMappingInfo.ExecutionMode,'Free running')||...
    strcmp(targetMappingInfo.ExecutionMode,'Coprocessing - blocking')||...
    strcmp(targetMappingInfo.ExecutionMode,'Coprocessing - nonblocking with delay'));
    hDI.set('ExecutionMode',targetMappingInfo.ExecutionMode);

    clockFreq=targetMappingInfo.ClockFrequency;
    hDI.setTargetFrequency(eval(clockFreq));
    hDI.initTargetInterface;


    for k=1:length(targetMappingInfo.PortNames)
        hDI.setTargetInterface(targetMappingInfo.PortNames{k},...
        targetMappingInfo.InterfaceNames{k});
        portAddr=dec2hex(str2double(targetMappingInfo.PortAddresses{k}));
        portAddr=['x"',portAddr,'"'];%#ok
        hDI.setTargetOffset(targetMappingInfo.PortNames{k},portAddr);
    end

    hDI.dispTargetInterface;

    validateCell=hDI.validateTargetInterface;%#ok
    hDI.runTurnkeyCodeGen;
    hDI.runTurnkeySynthesis;


    mcsExe=RTW.transformPaths(fullfile(xpcroot,'xpc\bin\mcs2c.exe'));
    [~,mcsFileName,~]=fileparts(hDI.getMCSFileName);



    mcsFilePath=['"',fullfile(pwd,hDI.getMCSFilePath),'"'];


    if strcmp(targetMappingInfo.hdlBoardName,'Speedgoat IO321-5')


        mcsFileName=[mcsFileName(1:length(mcsFileName)-3),'321'];
    end


    fileName=[mcsFileName,'.c'];
    varName=[mcsFileName,'_code'];
    system([mcsExe,' ',mcsFilePath,' ',fileName,' ',varName]);

end


