classdef ModelManager<handle






    properties

hPC


ModelName


Network


InputImages


DeployableIR

    end

    methods
        function obj=ModelManager(hPC)


            obj.hPC=hPC;
        end

        function openDLModel(obj,varargin)



            p=inputParser;

            addParameter(p,'Network',[]);


            addParameter(p,'InputImages',[],@dnnfpga.apis.Workflow.validateInputImages);
            addParameter(p,'LoadModelOnly',false,@(x)islogical(x));
            addParameter(p,'SimulationTime',9000,@(x)isnumeric(x)&&isreal(x));
            addParameter(p,'CopyModel',true,@(x)islogical(x));


            parse(p,varargin{:});
            net=p.Results.Network;
            image=p.Results.InputImages;
            loadModelOnly=p.Results.LoadModelOnly;
            simTime=p.Results.SimulationTime;
            copyModel=p.Results.CopyModel;

            if(~dnnfpga.compiler.canCompileNet(net,false))
                msg=message('dnnfpga:simulation:InvalidNetwork');
                error(msg);
            end


            if isempty(image)
                image=rand(net.Layers(1).InputSize);
            end


            hProcessorModel=obj.hPC.createProcessorModel(0);
            obj.preModelSetup(net,image,true,simTime);


            obj.Network=net;
            obj.InputImages=image;








            obj.ModelName=hProcessorModel.getModelName;
            if copyModel
                try
                    bdclose(obj.ModelName);
                    templateModelPath=fullfile(matlabroot,...
                    fullfile('toolbox','dnnfpga','dnnfpga','model','cnn5processor'),...
                    strcat(obj.ModelName,'.slx'));
                    copyfile(templateModelPath,pwd,'f');
                catch ME
                    throw(ME);
                end
            end


            hProcessorModel.loadModel(~loadModelOnly);


            obj.applySettingsToModel(hProcessorModel.getModelName,...
            hProcessorModel.getHWDUTPath);

        end

        function simulateAndValidateModel(obj,varargin)


            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;


            p=inputParser;


            addParameter(p,'RelativeTolerance',1e-4,@(x)isnumeric(x)&&isreal(x));
            addParameter(p,'AbsoluteTolerance',1e-4,@(x)isnumeric(x)&&isreal(x));


            addParameter(p,'CheckDoneSignal',false,@(x)islogical(x));
            addParameter(p,'DeployableIR',obj.DeployableIR);
            addParameter(p,'InputImages',obj.InputImages,@dnnfpga.apis.Workflow.validateInputImages);
            addParameter(p,'ModelName',obj.ModelName);
            addParameter(p,'Network',obj.Network);
            addParameter(p,'Testcase',[]);


            parse(p,varargin{:});
            absoluteTolerance=single(p.Results.AbsoluteTolerance);
            relativeTolerance=single(p.Results.RelativeTolerance);
            testCase=p.Results.Testcase;
            checkDoneSignal=p.Results.CheckDoneSignal;
            modelName=p.Results.ModelName;
            deployableIR=p.Results.DeployableIR;
            net=p.Results.Network;
            images=p.Results.InputImages;
            if isempty(testCase)
                testCase=matlab.unittest.TestCase.forInteractiveUse;
            end


            if bdIsLoaded(modelName)

                try

                    modelIfc=dnnfpga.interact.ModelInterface(modelName);


                    modelIfc.start();
                    modelIfc.awaitStopped();


                    ddrMem=modelIfc.getMem(0);
                    DLResults=net.predict(images,'ExecutionEnvironment','cpu');
                    DLHDLResults=cast(dnnfpga.dagnet.shared.readData(deployableIR.outputs,ddrMem),'like',DLResults);

                    if checkDoneSignal


                        doneSignalOutputBlockName=[modelName,'/TB/DoneSignalToWorkSpace'];
                        blockExisted=getSimulinkBlockHandle(doneSignalOutputBlockName)>0;
                        if blockExisted
                            doneSignalName=get_param(doneSignalOutputBlockName,'VariableName');
                            doneSignalData=evalin('base','out').(doneSignalName).Data;
                            if~any(doneSignalData)
                                msg=message('dnnfpga:customLayer:IncreaseSimulationTime',simulationTime);
                                error(msg);
                            end
                        end
                    end









                    isFormatOneByOneByN=sum(size(DLHDLResults,1:2)==1)>1;
                    if isFormatOneByOneByN
                        DLHDLResults=dnnfpga.bitstreambase.fpgaDeployment.formatPredictions(DLHDLResults);
                    end


                    testCase.verifyThat(DLHDLResults,IsEqualTo(DLResults,...
                    'Within',AbsoluteTolerance(absoluteTolerance)|RelativeTolerance(relativeTolerance)));
                catch ME









                    if(strcmp(ME.identifier,'dnnfpga:customLayer:IncreaseSimulationTime'))
                        throw(ME);
                    else
                        msg=message('dnnfpga:customLayer:ErrorVerifyNetwork',modelName);
                        error(msg);
                    end
                end
            else

                msg=message('dnnfpga:customLayer:ModelNotLoaded');
                error(msg);
            end
        end

        function preModelSetup(obj,net,image,validateKernel,simTime)


            if nargin<5
                simTime=9000;
            end


            dnnfpga.dagnet.shared.setup;
            exponentsData=load('exponentsData.mat');


            cnnp=obj.hPC.createProcessorObject;
            cc=cnnp.getCC();


            if(strcmp(obj.hPC.ProcessorDataType,'int8'))
                deployableNW=dnnfpga.compiler.codegenfpga(net,cnnp,'verbose',0,'exponentData',exponentsData.exponentsData,'processorConfig',obj.hPC,'ValidateTrimmableKernel',validateKernel);
            else
                deployableNW=dnnfpga.compiler.codegenfpga(net,cnnp,'verbose',0,'ProcessorConfig',obj.hPC,'ValidateTrimmableKernel',validateKernel);
            end
            inputData=deployableNW.activations(image,'InputToFPGA','FixedPointOutput',true);


            fpgaLayer=deployableNW.getSingletonFPGALayer();
            initData=fpgaLayer.getData();
            hasConv=isfield(initData.weights,'conv');
            hasFC=isfield(initData.weights,'fc');


            obj.DeployableIR=fpgaLayer.getDepolyableIR(true);


            TB.ramSrcLibPath='dnnfpgaSharedGenericlib/Simple Dual Port RAM System Forced Addr';
            TB.frameNum=1;
            TB.inputDDROffset=0;
            TB.outputDDROffset=0;
            TB.FcIPDDRAddr=0;
            TB.FcOPDDRAddr=0;
            TB.IP0syncID=2;
            TB.IP1syncID=3;
            TB.OP0syncID=4;
            TB.convsyncID=5;
            TB.IP0progID=6;
            TB.IP1progID=7;
            TB.OP0progID=8;
            TB.convprogID=9;

            if hasConv
                TB.lcDataIP0Prog=initData.instructions.conv.ip;
                temp=typecast(TB.lcDataIP0Prog,'uint32');
                temp(5:14:end)=temp(5:14:end)-temp(5);
                TB.lcDataIP0Prog=typecast(temp,'single');

                TB.lcDataIP1Prog=initData.instructions.conv.ip;
                TB.lcDataOP0Prog=initData.instructions.conv.op;
                TB.lcDataConvProg=initData.instructions.conv.conv;

                TB.lcDataIP0Sync=initData.syncInstructions.ip;
                TB.lcDataIP1Sync=initData.syncInstructions.ip;
                TB.lcDataOP0Sync=initData.syncInstructions.op;
                TB.lcDataConvSync=initData.syncInstructions.conv;
            else
                TB.lcDataIP0Prog=typecast(uint32(1:10),'single');
                TB.lcDataIP1Prog=typecast(uint32(1:10),'single');
                TB.lcDataOP0Prog=typecast(uint32(1:10),'single');
                TB.lcDataConvProg=typecast(uint32(1:10),'single');
                TB.lcDataIP0Sync=typecast(uint32(1:10),'single');
                TB.lcDataIP1Sync=typecast(uint32(1:10),'single');
                TB.lcDataOP0Sync=typecast(uint32(1:10),'single');
                TB.lcDataConvSync=typecast(uint32(1:10),'single');
            end

            seqLCLength=max(length(TB.lcDataIP0Prog),length(TB.lcDataIP1Prog));
            seqLCLength=max(seqLCLength,length(TB.lcDataOP0Prog));
            seqLCLength=max(seqLCLength,length(TB.lcDataConvProg));
            seqLCLength=max(seqLCLength,length(TB.lcDataIP0Sync));
            seqLCLength=max(seqLCLength,length(TB.lcDataIP1Sync));
            seqLCLength=max(seqLCLength,length(TB.lcDataOP0Sync));
            seqLCLength=max(seqLCLength,length(TB.lcDataConvSync));
            TB.delayLoadSeqLC=2*seqLCLength+10;

            TB.convLCData=[TB.lcDataIP0Prog,TB.lcDataConvProg,TB.lcDataOP0Prog];
            TB.threadNum=cc.convp.conv.threadNumLimit*cc.convp.conv.opW*cc.convp.conv.opW;
            TB.numOfResults=ceil(size(image,1)/cc.convp.conv.opW)*cc.convp.conv.opW*ceil(size(image,2)/cc.convp.conv.opW)*cc.convp.conv.opW*cc.convp.conv.threadNumLimit;
            TB.numOfResults=max(seqLCLength,TB.numOfResults);
            TB.tSim=simTime;
            TB.tScale=1;
            TB.debugMemAddrW=fixdt(0,cc.debug.debugMemAddrW,0);
            weightDebugMemDepthLimit=65536;
            weightDebugMemAddrW=ceil(log2(weightDebugMemDepthLimit));

            TB.dataTransNum=cc.dataTransNum;
            TB.activationKernalDataType=obj.hPC.ProcessorDataType;
            TB.aDDRData=reshape(inputData,[TB.dataTransNum,length(inputData)/TB.dataTransNum]);

            if hasFC
                TB.fcLCData=initData.instructions.fc;
                nc=initData.registers.fc;
            else
                TB.fcLCData=[];
                nc.layerNumMinusOne=0;
            end

            if~isempty(cc.convp)
                TB.BMInputTypeBit=cc.convp.conv.opBitWidthLimit;
                TB.BMInputVectorSize=cc.convp.conv.opDDRRatio;
                TB.BMOutputTypeBit=cc.convp.conv.opDUTBitWidthLimit;
                TB.BMOutputVectorSize=cc.convp.conv.opBitWidthLimit*cc.convp.conv.opDDRRatio/cc.convp.conv.opDUTBitWidthLimit;
            elseif~isempty(cc.fcp)
                TB.BMInputTypeBit=cc.fcp.opBitWidthLimit;
                TB.BMInputVectorSize=cc.fcp.opDDRRatio;
                TB.BMOutputTypeBit=cc.fcp.opDUTBitWidthLimit;
                TB.BMOutputVectorSize=cc.fcp.opBitWidthLimit*cc.fcp.opDDRRatio/cc.fcp.opDUTBitWidthLimit;
            end


            if hasConv
                seqOpConv=initData.weights.conv;
                TB.convWeightDDRData=[dnnfpga.assembler.castToIOBitWidthInVector(seqOpConv,ceil((prod(cc.convp.conv.opSize)*cc.convp.conv.threadNumLimitSquared+cc.convp.conv.threadNumLimit)/cc.convp.conv.opDDRRatio)*cc.convp.conv.opDDRRatio,cc.convp.conv.opBitWidthLimit*cc.convp.conv.opDDRRatio),zeros(cc.convp.conv.opDDRRatio,60)];
            else
                seqOpConv=[];
                TB.convWeightDDRData=seqOpConv;
            end
            if hasFC
                seqOpFC=initData.weights.fc;
                TB.fcWeightDDRData=[dnnfpga.assembler.castToIOBitWidthInVector(seqOpFC,cc.fcp.opDDRRatio,cc.fcp.opBitWidthLimit*cc.fcp.fixedBitSlice*cc.fcp.opDDRRatio),zeros(cc.fcp.opDDRRatio,120)];
            else
                seqOpFC=[];
                TB.fcWeightDDRData=seqOpFC;
            end
            if~isempty(cc.convp)
                TB.wDDRDataType='fixdt(0, cc.convp.conv.opBitWidthLimit, 0)';
                TB.wDDROutDataTypeBits=cc.convp.conv.opBitWidthLimit*cc.convp.conv.opDDRRatio;
            elseif~isempty(cc.fcp)
                TB.wDDRDataType='fixdt(0, cc.fcp.opBitWidthLimit, 0)';
                TB.wDDROutDataTypeBits=cc.fcp.opBitWidthLimit*cc.fcp.opDDRRatio;
            end
            TB.wDDRData=[TB.convWeightDDRData,TB.fcWeightDDRData];

            if isempty(TB.wDDRData)
                TB.wDDRData=zeros(4,10);
            end


            TB.convWeightDDRAddr=0;
            TB.fcWeightDDRAddr=numel(TB.convWeightDDRData)*4;



            TB.fcLCDDRLen=length(TB.fcLCData);
            TB.fcLCDDRAddr=4*length(TB.lcDataIP0Prog)+4*length(TB.lcDataConvProg)+4*length(TB.lcDataOP0Prog);


            if isfield(initData.instructions,'adder')
                TB.adderLCData=initData.instructions.adder;
            else
                TB.adderLCData=[];
            end

            TB.adderLCDDRLen=length(TB.adderLCData);
            TB.adderLCDDRAddr=TB.fcLCDDRAddr+4*TB.fcLCDDRLen;


            TB.skdLCData=initData.instructions.scheduler;
            TB.skdLCDDRLen=length(TB.skdLCData);
            TB.skdLCDDRAddr=TB.adderLCDDRAddr+4*TB.adderLCDDRLen;


            TB.LCData=[TB.convLCData,TB.fcLCData,TB.adderLCData,TB.skdLCData];


            assignin('base','nc',nc);
            assignin('base','cc',cc);
            assignin('base','TB',TB);
            assignin('base','weightDebugMemAddrW',weightDebugMemAddrW);

        end

        function applySettingsToModel(obj,modelName,HWDUTPath)





            set_param(HWDUTPath,'TreatAsAtomicUnit','on');


            hdlset_param(modelName,'AcquireDesignDelaysForEMLOptimizations','on');
            hdlset_param(modelName,'DistributedPipeliningBarriers','off');
            hdlset_param(modelName,'HighlightClockRatePipeliningDiagnostic','off');
            hdlset_param(modelName,'HighlightFeedbackLoops','off');
            hdlset_param(modelName,'ScalarizePorts','dutlevel');
            hdlset_param(modelName,'GenerateModel','off');
            hdlset_param(modelName,'GenerateCoSimModel','ModelSim');


            hdlset_param(modelName,'GenerateValidationModel','off');


            hdlset_param(modelName,'EDAScriptGeneration','off');
            hdlset_param(modelName,'HDLSubsystem',HWDUTPath);
            hdlset_param(modelName,'Workflow','Deep Learning Processor');



            hBoard=obj.hPC.getBoardObject;
            hdlset_param(modelName,'TargetPlatform',hBoard.BoardName);

            hdlset_param(modelName,'ReferenceDesign',obj.hPC.ReferenceDesign);
            hdlset_param(modelName,'SynthesisTool',obj.hPC.SynthesisTool);
            hdlset_param(modelName,'SynthesisToolChipFamily',obj.hPC.SynthesisToolChipFamily);
            hdlset_param(modelName,'SynthesisToolDeviceName',obj.hPC.SynthesisToolDeviceName);
            hdlset_param(modelName,'SynthesisToolPackageName',obj.hPC.SynthesisToolPackageName);
            hdlset_param(modelName,'SynthesisToolSpeedValue',obj.hPC.SynthesisToolSpeedValue);


            hdlset_param(modelName,'TargetFrequency',obj.hPC.TargetFrequency);


            fpConfig=obj.getFloatingPointTargetConfig();
            hdlset_param(modelName,'FloatingPointTargetConfiguration',fpConfig);


            obj.setupHDLFeatureControls;
        end

        function setupHDLFeatureControls(~)






            hdlfeature('NFPLogApprxImpl','on');

            hdlfeature('DNNFPGACodegen','on');
            hdlfeature('CheckMinAlgLoopOccurrences','off');




            hdlfeature('GenEMLHDLCounter','on');
        end


        function fpConfig=getFloatingPointTargetConfig(obj)



            switch obj.hPC.SynthesisTool
            case 'Xilinx Vivado'
                fpConfig=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint'...
                ,'LatencyStrategy','MIN','MantissaMultiplyStrategy','FullMultiplier');
            case 'Altera QUARTUS II'
                if(strcmpi(obj.hPC.ProcessorDataType,'int8'))
                    fpConfig=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint'...
                    ,'LatencyStrategy','MIN','MantissaMultiplyStrategy','FullMultiplier');
                else
                    fpConfig=hdlcoder.createFloatingPointTargetConfig('ALTERAFPFUNCTIONS','IPConfig',{});
                end
            otherwise
                fpConfig=[];
            end
        end
    end

end
