classdef CascadeArch<hdlimplbase.EmlImplBase



    methods
        function this=CascadeArch(block)
            supportedBlocks={'none'};

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);


        end

    end

    methods
        val=allowDistributedPipelining(this,hC)
        hNewNet=elabSerialOperation(this,hN,opName,ipf,bmp,hInType,refSLHandle,upRate,hSignalsIn)
        validSig=findSignalWithValidRate(this,hN,hC,hSignals)
        serializerComp=getCascadeSerializer(this,hN,hInSignals,hOutSignals,name,enbSig)
        decomposition=getDecomposition(this)
        val=getMaxOversampling(this,hC)
        val=getStateInfo(this,hC)
    end


    methods(Hidden)
        cascadeExpandCgirComp(this,hN,hC,opName,opOutType,ipf,bmp,tSignalsIn,tSignalsOut,casName,cascadeNum)
        cascadeStageCgirComp(this,hN,hC,opName,decomposeStage,ipf,bmp,hSignalsIn,hSignalsOut,decompose_vector,isStartStage,casName,cascadeNum)
        outputComp=elabCascadeArchitecture(this,hN,hC,hSignalsIn,hSignalsOut,ipf,bmp,opName,casName,cascadeNum)
        elabCascadeBlock(this,hN,hC,hSignalsIn,hSignalsOut,ipf,bmp,opName)
        elabCascadeStage(this,hN,opName,decomposeStage,ipf,bmp,hSignalsIn,hSignalsOut,isStartStage,casName,cascadeNum,inVldSignal,hSerialNet,cascadeEnbSignal)
        generateClocks(this,hN,hC)
        demuxComp=getCascadeController(this,hN,hInSignals,hOutSignals,decomposeStage,name)
        demuxComp=getCascadeController2(this,hN,hInSignals,hOutSignals,count_limit,mode_pre_in,name)
        latencyInfo=getLatencyInfo(this,hC)
    end

end

