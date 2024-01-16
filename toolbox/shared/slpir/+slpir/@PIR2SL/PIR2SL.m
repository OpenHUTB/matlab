classdef PIR2SL<handle

    properties
hPir
Verbose
InModelFile
OutModelFile
TopOutModelFile
OutModelFilePrefix
OutModelWorkSpace
RootNetworkName
SourceModelValid
SetDataTypesFromPir
ShowModel
DUTMdlRefHandle
TotalRunTime
FixedStepSize
SolverName
tunablePorts
ShowCodeGenPIR
SaveTemps
AutoRoute
AutoPlace
SLEngineDebug
UseModelReference
HiliteAncestors
HiliteColor
pirLayout
subsystemCache
TargetModelCC
MLMode
HyperlinksInLog
SampleTime
OverrideSampleTime
UseArrangeSystem
nonTopDut
SamplesPerCycle
    end


    methods
        function this=PIR2SL(hPir,varargin)
            if~isa(hPir,'hdlcoder.pirctx')
                error(message('hdlcoder:engine:SimulinkBackEnd'));
            end
            if mod(length(varargin),2)==1
                error(message('hdlcoder:engine:simulinkbackendpvpairs'));
            end

            this.hPir=hPir;

            this.SaveTemps='no';

            this.AutoRoute='on';

            this.AutoPlace='on';

            this.UseArrangeSystem='off';

            this.SLEngineDebug='off';

            this.UseModelReference='no';

            this.TotalRunTime='0.0';
            this.SolverName='FixedStepDiscrete';
            this.FixedStepSize='auto';
            this.subsystemCache=containers.Map();

            this.OutModelFile='';
            this.TopOutModelFile='';
            this.OutModelWorkSpace=[];
            this.ShowModel='yes';
            this.MLMode=false;
            this.HyperlinksInLog=true;

            this.RootNetworkName='';
            this.SourceModelValid=0;
            this.DUTMdlRefHandle=0;
            this.nonTopDut=0;
            this.SampleTime=-1;

            this.OverrideSampleTime=false;

            this.SetDataTypesFromPir='no';

            for n=1:2:length(varargin)
                this.(varargin{n})=varargin{n+1};
            end
        end
        connectNtwkGenericPorts(this,hN,tgtParentPath);
        [blkName,slHandle]=addBlock(this,hC,blkType,blkNameWithPath,makeNameUnique);
        handleMaskParams(this,slBlockName,slHandle,hRefNtwk,isPort,newPortNum);
        drawSLBlockFromPirComp(this,tgtParentPath,hC);
        slBlockName=drawSLSubsystem(this,slBlockName,hC);
        setProperties(this,hC,slbh);
        sltype=computeDataType(this,hT,forceFixdtType);
        dims=getDimensionsStr(this,hT);
        addInportBlocks(this,tgtParentPath,hNtwkOrComp,isDUT);
        addOutportBlocks(this,tgtParentPath,hNtwk);
        portAdded=addInBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hNtwkSlHandle);
        portAdded=addOutBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hNtwkSlHandle);
        setBusElementPortAttributes(this,srcBepObj,dstBepH,setMqAttributes);
        sampleTimeStr=setPortSampleTime(this,signal,hcc,portHandle,isInTriggeredNet);
        addSubSystemPorts(this,subSysPath,hRefNtwk);
        drawRTWCGBlock(this,slBlockName,hC);
        convert2VariantSystem(this,hC,blockNameWithFullPath);
        setPorts(this,blockNameWithFullPath,hRef,hC);
        drawBlockFromUser(this,tgtParentPath,hC);
        drawComps(this,tgtParentPath,hN);
        drawNetwork(this,srcParentPath,hN);
        setDataType(this,slBlockName,sltype);
        setOutDataTypeStr(this,slBlockName,sltype);
        retval=formatVal(this,val,isUsedInEval);
        retval=formatMatrixVal(this,val,isUsedInEval);
        retval=formatCell(this,val,isUsedInEval);
        generateOrigModel(this);
        applyDotLayoutInfo(this,parentPath,hN);
        copyDut(this);
        createAndInitTargetModel(this,isInterfaceModel);
        createTargetModel(~,modelName);
        drawBlkEdges(this,mdlFile,hN);
        drawEMLBlock(this,emlBlockName,hC);
        drawSLBlocks(this,hPir);
        drawTestBench(this,includeDut,emitMessage,convertModel);
        outstr=fixNameForDot(this,instr);
        generateModel(this);
        dialogParams=getMaskDlgParams(this,slBlock);
        maskParams=getMaskParams(this,slBlock);
        outMdlFile=getOutModelFile(this,forceClose);
        mdlPath=getTargetModelPath(this,srcParentPath);
        u=getUniqueEmlParamNum(this,clear);
        codingForModel=isDutWholeModel(this);
        isSF=isSFNetwork(this,slbh);
        needMdlGenForDut=needFullMdlGen(this);
        needsFullModelGen=needsFullModelGenForDut(this);
        postModelgenTasks(this,hPir,mpd);
        preparePirForModelGen(this);
        flag=renderCodeGenPIR(this,hN);
        resolveOutModelFile(this,forceClose);
        setMaskDlgParams(this,slBlockName,pv);
        [success,statusMsg]=setMaskParams(this,slBlockName,pv);
        startLayout(this);
        reportCheck(~,lvlB,msgObj,varargin);
        genmodeldisp(~,msg,level,flag);
        paramvalue=genmodelgetparameter(~,param);
        drawTest(this);
        drawStreamedTestBench(this);


        function newSlBlockName=drawSerializerComp(~,~,~)
            newSlBlockName='';
        end


        function newSlBlockName=drawTappedDelayEnabledResettableComp(~,~,~)
            newSlBlockName='';
        end


        function newSlBlockName=drawDeserializerComp(~,~,~)
            newSlBlockName='';
        end


        function newSlBlockName=drawRecipSqrtNewtonComp(~,~,~)
            newSlBlockName='';
        end


        function newSlBlockName=drawSqrtNewtonComp(~,~,~)
            newSlBlockName='';
        end


        function drawReciCompNewtonImp(~,~,~)
        end


        function modelgenset_param(~,varargin)
        end


        function chevrontrigport=isChevronTriggPort(~,hC)
            chevrontrigport=false;
            sl=hC.SimulinkHandle;
            if~isa(hC,'hdlcoder.network')&&~hC.isAnnotation&&sl>0
                bt=get_param(sl,'BlockType');
                if strcmp(bt,'ArgIn')||strcmp(bt,'ArgOut')||strcmp(bt,'TriggerPort')
                    chevrontrigport=true;
                end
            end
        end

    end


    methods(Abstract)
        notdraw=shouldDrawComp(~,hC);
        valid=isValidComp(~,hC,useDotLayout);
        valid=isValidPort(~,hP);
    end


    methods(Static)
        initOutputModel(srcModelName,targetModelName);
        drawTunableConstBlocks(tunablePorts,DUTName,subsystemOnDUT);
        connectTestpoints(dummy,gmDUT,gmTop);
        drawCordicTrigBlocks(hC,originalBlkPath,newSlSubsystemName,fcn,iterNum,usePipelines,customLatency,latencyStrategy)

        clearNameMap(~);

        rMap=getNameMapSingletonInstance(~);
        uniqueName=getUniqueName(slBlockName);
    end
end


