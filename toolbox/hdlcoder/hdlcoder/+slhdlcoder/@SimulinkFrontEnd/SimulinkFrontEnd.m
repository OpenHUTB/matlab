classdef SimulinkFrontEnd<handle




    properties(Access=private)
AssertionCompPresent
BustoVectorBlocks
CheckSumNtwkMap
HDLCoder
HandleReusableSubsystem
hParamArgMap
ReusableSSBlks

TreatAsReferencedModel
        InBlockSSPIRConstruction=0;
    end

    properties(Access=public)
BusExpandedBlocks
CheckSumInfo
hPir
ReusedSSBlks
ReusedSSReport
MaskedSubsystemLibraryBlocks
ModelCheckSum

NoReuseInlineParamsOff

NoReuseTunableMaskParams

NoReuseReadOnlySubsystems
        SimulinkConnection;
    end

    methods
        function this=SimulinkFrontEnd(hdlCoder,slconnection,...
            hPir,treatAsReferencedModel)
            if~isa(slconnection,'slhdlcoder.SimulinkConnection')
                error(message('hdlcoder:engine:simulinkfrontendinvalidconnection'));
            end

            if~isa(hPir,'hdlcoder.pirctx')
                error(message('hdlcoder:engine:simulinkfrontendinvalidpirobject'));
            end

            this.SimulinkConnection=slconnection;
            this.hPir=hPir;
            this.HDLCoder=hdlCoder;
            this.TreatAsReferencedModel=treatAsReferencedModel;
            this.hParamArgMap=containers.Map();
            this.AssertionCompPresent=false;
            this.NoReuseInlineParamsOff=false;
        end

        addDutRate(this,blkh)
        port=addTriggerPort(this,hThisNetwork,triggerPort)
        annotateMaskParamInfo(this,maskInfo,hChildNetwork,hNtwkInstComp,...
        foundPirNtwkForSS)
        annotationInstantiation(this,annoblocks,configManager,hThisNetwork)
        blockInstantiation(this,topslbh,blockInfo,configManager,hThisNetwork)
        checkBlock(this,blockOrBlockHandle)
        blockInfo=classifyblocks(this,blocklist,doChecks)
        cleanupHDLParams(this,slbh,~)
        [maskInfo,unsupportedParam]=collectMaskParamInfo(this,slbh,configManager)
        collectTopMaskParamInfo(this,blockInfo,configManager,thisNtwk)
        connectBusExpansionSubsystem(this,blocklist,hN)
        connectVariantSusbsystem(this,blocklist,hThisNetwork)
        connectSignals(this,blocklist,hN)
        hThisNetwork=constructPIR(this,slName,configManager)
        hTopNetwork=createNetworkforDirectBlock(this,startNodeName,configManager);
        createNetworksForSF(this)
        pirrecord=createPIRrecordType(this,slbh,portH,sigHier)
        hC=findComponentUnderNetwork(this,hNet,slhandle)
        generatePIR(this,configManager,checkhdl)
        refMdlPrefix=getReferenceModelPrefix(this,impl,refMdlName,blockPath)
        sigRate=getSigRate(this,oportHandle)
        [frontendstop,bboxsystem]=isAFrontEndStopSubsystem(~,impl,blockPath)
        [reuse_ss,checksumStr,hChildNetwork]=isHandledReusableSS(this,blockPath)
        markBustoVectorConversion(this,hsig,dstBlk,portNum,hC)
        hC=pirAddComponent(this,slbh,hThisNetwork)
        pirAddNetworkPorts(this,hThisNetwork,blockInfo,configManager)
        hC=pirAddNtwkInstanceComp(this,slbh,hThisNetwork,hChildNetwork)
        impl=pirGetImplementation(this,slbh,configManager)
        hS=pirGetSignal(this,hThisNetwork,slbh,oportHandle)
        postConstructionPhase(this)
        processVectorizedInstances(this)
        readModelRefMaskParams(this,slbh,blockPath,refNtwk,hNewC)
        newblocklist=resolveAndCheckIterationBlocks(~,blocklist,hN)
        newblocklist=resolveSyntheticModelRefBlocks(~,blocklist)
        newblocklist=resolveInactiveBlocks(~,blocklist)
        prunedCompiledBlockList=pruneUnnecessaryNoHDLBlocks(~,compiledBlockList)
        setImplAndParams(this,hC,slbh,configManager)
        setNetworkRefCompParams(this,thisNetwork,configManager,...
        blockPath,checkSampleTime)
        setPipelineInfo(~,hC,impl)
        setSubsystemParams(this,configManager,thisNetwork)
        setSubsystemStateControl(this,blockInfo,thisNetwork)
        setupAndInitModel(this,configManager)
        setupHDLParams(this,slbh,configManager)
        toplevelMaskParamInfo(this,slName,configManager,hTopNetwork)
        updateBlocksWithHDLImplParams(this,startNodeName,configManager,blkFn)
        updateChecks(this,blkpath,type,msgobj,level)
        str=validateAndGetName(this,strin)
        validateBusExpansionSubsystem(this,blockName,slbh)
        checks=validatePIR(~,hPir)
        analyzeReusedSSBlks(this);
    end

    methods(Static,Access=private)
        annotatePIR(p)
        connectSynthBlocks(syntheticblocks,hThisNetwork)
        isScalar=isascalartype(portDims)
        isBusElementIsArray=isArrayInsideBus(busSigHier,slbh)
        [valid,msgobj,level]=isaValidType(slSignalType,portDims)
        blkH=isConcExecSubsystem(slbh,modelName)
        handled=isHandledSyntheticBlock(slbh)
        isRSS=isIPBlockRecurseSS(impl)
        blkH=isMatlabSystemBlockSubsystem(slbh)
        flag=isStateFlowReactiveTestingBlock(blockPath)
        busObj=getSlResolvedBusObject(busName,slbh)
    end

    methods(Static,Access=public)
        isBESS=isBusExpansionSubsystem(slbh)
        isBEBlock=isBusExpansionBlock(slbh)
        synthetic=isSyntheticBlock(slbh)
        [sigName,preserve]=pirGetSignalName(slbh,oportHandle)
        [msgobj,level,val]=validateAndSetNetworkParam(subsysImplParam,blockPath,network,checkSampleTime)
        [isMathWorksLib,isUnregistered,isFullySupported]=getInternalLibraryBlockInfo(slbh,impl);
    end
end
