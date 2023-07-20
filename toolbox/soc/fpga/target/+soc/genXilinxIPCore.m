function genXilinxIPCore(hbuild,varargin)




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
            hWC=hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');
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
                mappingStr{j}={tunableParams{j},'AXI4-Lite',regOffset};
            end
            hdlset_param(thisBlk,'TunableParameterMapping',mappingStr);
        end

        fprintf('---------- Generating IPCore for %s ----------\n',thisBlk);


        hdlset_param(sys,'HDLSubsystem',thisBlk);
        hdlset_param(sys,'ReferenceDesign','Default system');
        hdlset_param(sys,'SynthesisTool','Xilinx Vivado');
        hdlset_param(sys,'SynthesisToolChipFamily','Zynq');
        hdlset_param(sys,'SynthesisToolDeviceName','xc7z020');
        hdlset_param(sys,'SynthesisToolPackageName','clg484');
        hdlset_param(sys,'SynthesisToolSpeedValue','-1');
        hdlset_param(sys,'TargetDirectory',fullfile(hdlCoderDir,thisDutName,'hdlsrc'));
        hdlset_param(sys,'TargetFrequency',25);
        hdlset_param(sys,'TargetPlatform','Generic Xilinx Platform for SoC Blockset');
        hdlset_param(sys,'Workflow','IP Core Generation');
        hdlset_param(sys,'ResetType','Synchronous');




        I2C_Master=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hwlogiciolib/I2C Master');
        I2C_SoC_Blk=get_param(I2C_Master,'Parent');
        if(~isempty(I2C_SoC_Blk))
            if strcmpi(thisBlk,I2C_SoC_Blk{1})

                hdlset_param(sys,'TargetLanguage','Verilog');
                hdlset_param(thisBlk,'IPCoreAdditionalFiles',fullfile(matlabroot,'toolbox','soc','fpga','target','hw','src','i2c_bidir.v'));

            end
        end



        hWC=hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');


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
    end
end
