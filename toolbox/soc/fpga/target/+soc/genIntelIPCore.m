function genIntelIPCore(hbuild,varargin)
    sys=hbuild.SystemName;
    memMap=hbuild.MemMap;
    if nargin==2
        dutList=varargin;
    else
        dutList=hbuild.DUTName;
    end
    prjDir=hbuild.ProjectDir;
    ipDir=fullfile(prjDir,'ipcore');
    hdlCoderDir=fullfile(prjDir,'hdlcoder');
    if~isfolder(ipDir)
        mkdir(ipDir);
    end
    if~isfolder(hdlCoderDir)
        mkdir(hdlCoderDir);
    end

    for i=1:numel(dutList)
        thisDut=dutList{i};
        thisBlk=[sys,'/',thisDut];
        thisDutName=regexprep(thisDut,'[\W]*','_');

        soc.util.getDUTIntfInfo(hbuild,thisBlk,memMap);


        try
            hDriver=hdlmodeldriver(sys);
            hDI=hDriver.DownstreamIntegrationDriver;
            hDI.hIP.reloadPlatformList;
        catch
        end






        try
            hdlset_param(sys,'HDLSubsystem',thisBlk);
            hdlset_param(sys,'Workflow','IP Core Generation');
            hdlset_param(sys,'TargetPlatform','');
            hWC=hdlcoder.WorkflowConfig('SynthesisTool','Altera QUARTUS II','TargetWorkflow','IP Core Generation');
            hdlcoder.runWorkflow(thisBlk,hWC);
        catch
        end


        set_param(thisBlk,'TreatAsAtomicUnit','on');


        tunableParams=soc.internal.getTunableParameter(thisBlk);
        NumTunableParams=numel(tunableParams);
        if NumTunableParams>0
            mappingStr=cell(1,NumTunableParams);
            for j=1:NumTunableParams
                regOffset=soc.memmap.getRegOffset(memMap,thisDut,tunableParams{j});

                regOffset=['x"',regOffset(3:end),'"'];
                mappingStr{j}={tunableParams{j},'AXI4',regOffset};
            end
            hdlset_param(thisBlk,'TunableParameterMapping',mappingStr);
        end

        fprintf('---------- Generating IPCore for %s ----------\n',thisBlk);



        hdlset_param(sys,'HDLSubsystem',thisBlk);
        hdlset_param(sys,'ReferenceDesign','Default system');
        hdlset_param(sys,'SynthesisTool','Altera QUARTUS II');
        hdlset_param(sys,'SynthesisToolChipFamily','Cyclone V');
        hdlset_param(sys,'SynthesisToolDeviceName','5CSXFC6D6F31C6');
        hdlset_param(sys,'SynthesisToolPackageName','');
        hdlset_param(sys,'SynthesisToolSpeedValue','');
        hdlset_param(sys,'TargetDirectory',fullfile(hdlCoderDir,thisDutName,'ip'));
        hdlset_param(sys,'TargetFrequency',25);
        hdlset_param(sys,'TargetPlatform','Generic Intel Platform for SoC Blockset');
        hdlset_param(sys,'Workflow','IP Core Generation');
        hdlset_param(sys,'ResetType','Synchronous');




        hWC=hdlcoder.WorkflowConfig('SynthesisTool','Altera QUARTUS II','TargetWorkflow','IP Core Generation');


        hWC.ProjectFolder=fullfile(hdlCoderDir,thisDutName);
        hWC.ReferenceDesignToolVersion='';
        hWC.IgnoreToolVersionMismatch=true;


        hWC.RunTaskGenerateRTLCodeAndIPCore=true;
        hWC.RunTaskCreateProject=false;
        hWC.RunTaskGenerateSoftwareInterfaceModel=false;
        hWC.RunTaskBuildFPGABitstream=false;
        hWC.RunTaskProgramTargetDevice=false;


        hWC.IPCoreRepository='';
        hWC.GenerateIPCoreReport=false;


        hWC.Objective=hdlcoder.Objective.None;
        hWC.AdditionalProjectCreationTclFiles='';


        hWC.OperatingSystem='';


        hWC.RunExternalBuild=false;
        hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Default;
        hWC.CustomBuildTclFile='';


        hWC.ProgrammingMethod=hdlcoder.ProgrammingMethod.JTAG;


        hWC.validate;


        hdlcoder.runWorkflow(thisBlk,hWC);


        copyfile(fullfile(hdlCoderDir,thisDutName,'ipcore'),fullfile(ipDir),'f');


        outp=find_system(thisBlk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
        ipcoreName=hdlget_param(thisBlk,'IPCoreName');
        fileName=fullfile(ipDir,[ipcoreName,'_v1_0'],[ipcoreName,'_hw.tcl']);
        fileData=fileread(fileName);
        for j=1:numel(outp)
            thisPortIntfInfo=hbuild.IntfInfo(outp{j});
            if~isempty(thisPortIntfInfo.interfacePort)&&strcmpi(thisPortIntfInfo.interfacePort,'interrupt')
                portName=get_param(outp{j},'name');
                fileData=regexprep(fileData,['add_interface ',portName,' conduit end'],...
                ['add_interface ',portName,' interrupt end']);
                fileData=regexprep(fileData,['add_interface_port ',portName,' ',portName,' pin Output 1'],...
                ['add_interface_port ',portName,' ',portName,' irq Output 1']);
            end
        end
        fid=fopen(fileName,'w+');
        fprintf(fid,fileData);
        fclose(fid);

    end
end