classdef HDLDirectCodeGen<imported.hdlcoder.HDLImplementationM



    properties

        CodeGenFunction='emit';

        FirstParam='useobjandcomphandles';

        CodeGenParams=[];

        validateFunction='validate';

        validateParams={};

        Blocks=cell(0,1);

        Description=[];

        CodeGenMode='emission';

        generateSLBlockFunction='generateSLBlock';

        implParamInfo={};

        implParams={};

        blkParams={};

        publishImpl=true;

        ArchitectureNames={};

        DeprecatedArchName={};

        Deprecates={};

        Hidden=false;
    end


    methods
        function this=HDLDirectCodeGen
        end

    end

    methods
        function set.FirstParam(obj,value)

            value=validatestring(value,{'useslhandle','usecomphandle','useobjandcomphandles'},'','FirstParam');
            obj.FirstParam=value;
        end

        function set.Blocks(obj,value)


            obj.Blocks=value;
        end

        function set.CodeGenMode(obj,value)

            value=validatestring(value,{'emission','instantiation'},'','CodeGenMode');
            obj.CodeGenMode=value;
        end

        function set.ArchitectureNames(obj,value)


            obj.ArchitectureNames=value;
        end

        function set.DeprecatedArchName(obj,value)


            obj.DeprecatedArchName=value;
        end

        function set.Deprecates(obj,value)


            obj.Deprecates=value;
        end

    end

    methods
        [hNewNet,hNewC]=addHDLComp(this,varargin)
        addImplParam(this,param,value)
        addImplParamInfo(this,implParamName,implParamType,implParamDefValue,implParamAllValues,panelLayout)
        addLatencyToOutports(~,hC,targetBlkPath,outputBlk,lastBlkPosition,color,outDelay)
        addSLBlockLatency(this,hC,targetBlkPath,latencyInfo,outputBlk,lastBlkPosition)
        newBlockPath=addSLBlockSubsystem(this,hC,originalBlkPath,targetBlkPath)
        val=allowDistributedPipelining(this,hC)
        hBlackBoxC=baseElaborate(this,hN,hC)
        value=baseImplParamNames(this)
        baseRegisterImplParamInfo(this)
        v=baseValidate(this,hC)
        v=baseValidateComplex(this,ports,msg)
        v=baseValidateFrames(this,hC)
        val=baseValidateGetPropValue(this,pvpairs,prop)
        v=baseValidateImplParams(this,~)
        v=baseValidatePortDatatypes(this,ports)
        v=baseValidateRealComplexPorts(this,ports)
        [noports,any_complex,all_complex]=checkForRealComplexPorts(this,ports)
        hBlackBoxC=createBlackBoxComp(this,hN,hC)
        [hNewNet,hNewC]=defHDLComp(this,varargin)
        hBBC=elabBasic(this,hN,hC)
        hNewC=elaborate(this,hN,hC)
        elaborateImplParams(this,hN,hC)
        [hNewC,hNewNet]=elaborateToNetworkInst(~,hN,hC)
        hdlcode=emitBlockComments(this,hC)
        fixblkinhdllib(this,blkh)
        generateClocks(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,delay)
        generateSLProtectedModel(~,hC,originalBlkPath,targetBlkPath)
        ports=getAllSLInputPorts(this,hC)
        blockFrameMode=getBlockFrameMode(this)
        blocks=getBlocks(this)
        str=getCodeGenMode(~)
        desc=getDescription(this)
        hdldata=getHDLUserData(~,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        v=getHelpInfo(this,blkPath)
        [turnhilitingon,color]=getHiliteInfo(~,~)
        latencyInfo=getHwModeLatency(this,hC)
        implParamInfo=getImplParamDefaults(this)
        ipInfo=getImplParamInfo(this)
        orderedParams=getImplParamOrder(this,iparamInfo)
        values=getImplParams(this,param)
        latencyInfo=getLatencyInfo(this,hC)
        val=getMaxOversampling(this,hC)
        [inPortNames,outPortNames]=getPortNamesFromSimulink(~,blockHandle)
        publish=getPublish(this)
        overClockRate=getSignalOverClock(this,signal)
        state=getStateInfo(this,hC)
        latencyInfo=getTotalCompLatency(this,hC)
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        maskParamInfo=getMaskParameterInfo(this,maskParamInfo)
        msgobj=validateMaskParameterInfo(this,maskParamInfo)
        val=hasDesignDelay(~,~,~)
        value=implParamNames(this)
        initHDLComp(this,hC,Name,HDLComp,BlockParam,input,output)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        mainEarlyElaborate(this,hN,hC)
        mainElaborate(this,hN,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        postEmit(this,hDriver,hComponent,context)
        oldContext=preEmit(this,hDriver,hComponent)
        registerImplParamInfo(this)
        panelLayout=registerNFPImplParamInfo(this,hasDenormal,hasMantissa,hasCustomLatency)
        removeImplParam(this,param)
        reporterrors(this,hC,v)
        setCompIoPortNames(this,hC,HDLComp)
        setHDLUserData(~,hC,hdldata)
        setImplParams(this,params)
        setModelParam(this,srcModelName,targetModelName,exceptions)
        setPseudoElabSettings(this,hN,hPreElabC,hPostElabC)
        setPublish(this,publish)
        signalType=setSignalType(this,varargin)
        v=validBlockMask(~,slbh)
        v=validate(this,hC)
        v=validateBlock(this,hC)
        v=validateComplex(this,hC,inMsg,outMsg)
        v=validateEnumParam(this,hC,param,legalvalues)
        v=validateFrames(this,hC)
        v=validateImplParams(this,hC)
        v=validateMatrices(~,hC,maxSupportedDims)
        v=validateNFP(this,hC)
        v=validateOnOffParam(this,hC,param)
        v=validateSlopeBias(this,hC)
        v=validateStringParam(this,hC,param)
    end


    methods(Hidden)
        hsig=addHDLSignal(this,varargin)
        [hNewNet,inSignal,outSignal]=addNewNetwork(this,hN,Name,inPort,outPort,refSLBlock,SLHandle,mode)
        blkName=addSLBlock(this,hC,blkType,blkNameWithPath,makeNameUnique,skipSampleTime)
        [outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,srcBlkPath,targetBlkPath,srcBlkParam)
        retval=allowElabModelGen(this,hN,hC)
        v=baseValidateEnabledSubstem(this,hN)
        v=baseValidateFramesInputProc(this,hC)
        v=baseValidateFramesInputProcandRateOpt(this,hC)
        v=baseValidateFramesRateOpt(this,hC)
        v=baseValidateMulticlock(~,~)
        v=baseValidateResettableSubstem(~,hC)
        v=baseValidateRetimingBlackbox(this,hN)
        v=baseValidateRetimingCompatibility(~,hN,hC)
        v=baseValidateSharing(this,hN)
        v=baseValidateSinglerateSharing(this,hN,hC)
        v=baseValidateSlopeBias(this,hC)
        v=baseValidateStreaming(this,hN)
        v=baseValidateVectorPortLength(this,port,allowedLength,err_msg)
        v=baseValidateVectorPorts(this,ports,varargin)
        v_settings=base_validate_settings(~)
        v_settings=block_validate_settings(this,hC)
        [noports,any_real,all_real,any_double,all_double,any_single,all_single,any_half,all_half]=checkForDoublePorts(~,ports)
        connectHDLBlk(this,handle,input,output)
        displayEmlCodegenMessage(this,hC)
        retval=forceElabModelGen(this,hN,hPreElabC)
        ports=gatherinputoutputports(this,hC)
        generateSubsystemWithLatency(this,hC,targetBlkPath,latencyInfo)
        ports=getAllPirInputPorts(this,hC)
        ports=getAllPirOutputPorts(this,hC)
        ports=getAllSLOutputPorts(this,hC)
        archName=getArchitectureName(this)
        blockFrameMode=getInputProcFrameMode(this)
        blockFrameMode=getInputProcandRateOptFrameMode(this)
        nfpOptions=getNFPBlockInfo(this)
        ret=getPotentiallyInsertsPipelines(this,hC)
        preferredName=getPreferredArchitectureName(this)
        blockFrameMode=getRateOptFrameMode(this)
        roParam=getRateOptionsParameter(~)
        v_settings=get_validate_settings(this,hC)
        sarray=hdlgetsignalarray(this,sigpointer)
        val=hdlslResolve(this,prop,block)
        hiliteBlkAncestors(this,blkPath,color)
        init(this,varargin)
        status=isBlockAtHighestRate(this,signal)
        category=libcategory(this,blk)
        blkName=localGetBlockName(this,slbh)
        val=mustElaborateInPhase1(~,~,~)
        optimize=optimizeForModelGen(this,hN,hC)
        hNewC=preElab(this,hN,hC)
        v=recurseIntoSubSystem(this)
        v=subSystemBasedHDLIP(this)
        [hNewNet,hNewC]=replaceCompWithNtwk(this,hN,hC)
        blockParam=setBlockParam(this,block,varargin)
        setBlockSampleTime(~,hC,blkpath,onlyIfSynthetic,paramname)
        setDelayTags(this,hPreElabC,hPostElabC)
        setSampleModeForBlock(this,blkh)
        params=slopeBiasParametersToCheck(this,hC)
        retval=usesSimulinkHandleForModelGen(this,hN,hC)
        v=validateAlteraMegafunctionCompatibility(~,hC)
        v=validateComplexTypesForTargetCodeGen(~,hC)
        v=validateEnabledSubsystem(this,hN)
        v=validateInputOutputPortDatatypes(this,hC)
        vstructs=validateMaskParams(~,~)
        v=validateMulticlock(this,hC)
        v=validatePortDatatypes(this,hC)
        v=validateResettableSubsystem(this,hC)
        v=validateRetimingBlackbox(this,hN)
        v=validateRetimingCompatibility(this,hN,hC)
        v=validateSharing(this,hN)
        v=validateSinglerateSharing(this,hN,hC)
        v=validateStreaming(this,hN)
        v=validateSumDatatypes(this,hC)
        v=validateTriggeredSubsystem(this,hN)
        v=validateVectorPorts(this,hC)
        v=validateXilinxCoregenCompatibility(~,hC)
        r=isCharacterizableBlock(~)
    end

end







