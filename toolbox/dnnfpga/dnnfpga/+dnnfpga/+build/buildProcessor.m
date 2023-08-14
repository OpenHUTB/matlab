function buildProcessor(hPC,varargin)





    try
        dnnfpga.utilscripts.checkUtility;
    catch ME

        throwAsCaller(ME);
    end



    if nargin<1

        hPC=dlhdl.ProcessorConfig();
        warning(message('dnnfpga:workflow:UsingDefaultConfig'));
    elseif~isa(hPC,'dnnfpga.config.ProcessorConfigBase')

        error(message('dnnfpga:workflow:InvalidProcessorConfig'));
    end


    p=inputParser;


    p.addParameter('ProjectFolder','dlhdl_prj');


    p.addParameter('ProcessorName','dlprocessor');


    p.addParameter('HDLCoderConfig',{});


    p.addParameter('OverrideResourceCheck',false);




    p.addParameter('WorkflowConfig',[]);





    p.addParameter('Verbose',1);


    p.addParameter('DUTConfig',{});


    p.addParameter('MakehdlOnly','off');


    p.addParameter('ShowModel','off');


    p.parse(varargin{:});
    args=p.Results;

    projectFolder=args.ProjectFolder;
    processorName=args.ProcessorName;
    hdlcoderConfig=args.HDLCoderConfig;
    overrideResourceChk=args.OverrideResourceCheck;


    verbose=args.Verbose;
    isMakehdlOnly=strcmpi(args.MakehdlOnly,'on');
    isShowModel=strcmpi(args.ShowModel,'on');
    dutConfig=args.DUTConfig;

    if(~hPC.isGenericDLProcessor())



        if(contains(hPC.SynthesisTool,'Xilinx'))
            dnnfpga.validateDLSupportPackage('Xilinx','buildProcessor');
        elseif(contains(hPC.SynthesisTool,'Intel')...
            ||contains(hPC.SynthesisTool,'Altera'))
            dnnfpga.validateDLSupportPackage('Intel','buildProcessor');
        end
        dnnfpga.validateDLSupportPackage('shared','multiple');
    end


    if~isempty(args.WorkflowConfig)

        hWC=args.WorkflowConfig;


        if~isa(hWC,'hwcli.config.DeepLearningConfig')

            error(message('dnnfpga:workflow:InvalidWorkflowConfig',hPC.SynthesisTool));
        end



    else

        hWC=hdlcoder.WorkflowConfig(...
        'SynthesisTool',hPC.SynthesisTool,...
        'TargetWorkflow','Deep Learning Processor');






        hWC.RunTaskGenerateRTLCodeAndIPCore=true;
        hWC.RunTaskCreateProject=true;
        hWC.RunTaskBuildFPGABitstream=true;
        hWC.RunTaskEmitDLBitstreamMATFile=true;









        if strcmpi(hPC.TargetPlatform,'Intel Arria 10 SoC development kit')&&contains(hPC.ReferenceDesign,'LIBIIO','IgnoreCase',true)
            hWC.RunExternalBuild=false;
        end






        hWC.RunExternalBuild=false;




        hWC.ReportTimingFailure=hdlcoder.ReportTiming.Warning;

    end


    if~isempty(hdlcoderConfig)
        dnnfpga.validateHDLCoderConfig(hPC,hdlcoderConfig);
    end



    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:GenDLProcUsingPC'))
    hPC.disp;


    hPC.validateProcessorConfig();

    if(~overrideResourceChk)
        try

            hPC.validateResourceAvailability;
        catch ME
            throwAsCaller(ME)
        end
    end


    hProcessorModel=hPC.createProcessorModel(verbose);


    hBitBuild=dnnfpga.build.DLBitstreamBuild(hWC,hProcessorModel,verbose);
    hBitBuild.runBitstreamBuild(isShowModel,isMakehdlOnly,hdlcoderConfig,dutConfig,projectFolder,processorName);



