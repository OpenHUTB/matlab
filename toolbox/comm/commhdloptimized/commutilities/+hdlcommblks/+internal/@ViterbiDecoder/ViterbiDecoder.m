classdef ViterbiDecoder<hdlcommblks.internal.AbstractCommHDL
































    methods
        function this=ViterbiDecoder(block)












            supportedBlocks={...
            'commcnvcod2/Viterbi Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Viterbi Decoder',...
            'HelpText','HDL Support for Viterbi Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'Register-based Traceback'});

        end

    end

    methods
        generateSLBlock(this,hC,targetBlkPath)
        val=hasDesignDelay(~,~,~)
        y=normvalReset_FSM(reset,delaylen)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        dins=demuxSignal(~,hN,inSignal,sname)
        ACSNet=elabACS(this,topNet,blockInfo,dataRate)
        [acsdec,nsm]=elabACSEngine(this,ACSNet,normedbm,bmvType,sm,t,stmetType,dataRate,decvType,stmetvType)
        renormNet=elabACSRenorm(this,ACSNet,idxType,blockInfo,thred,step,stmetType,stmetvType,ic,dataRate)
        acsunitNet=elabACSUnit(~,topNet,stmetType,dataRate)
        BMetNet=elabBMet(this,topNet,blockInfo)
        tbNet=elabTraceback(this,topNet,blockInfo,dataRate)
        tbNet=elabTracebackUnit(~,topNet,blockInfo,dataRate)
        nComp=elaborate(this,hN,hC)
        elaborateViterbiNetwork(this,topNet,blockInfo)
        blockInfo=getBlockInfo(this,hC)
        choice=getChoice(this)
        latencyInfo=getLatencyInfo(this,hC)
        blockInfo=getSysObjInfo(this,sysObj)
        muxSignal(~,hN,sArray,sVector)
        optimize=optimizeForModelGen(this,hN,hC)
        [thred,step,stmetNT]=renormparam(~,trellis,nsDec)
        v=validateBlock(this,hC)
    end

end

