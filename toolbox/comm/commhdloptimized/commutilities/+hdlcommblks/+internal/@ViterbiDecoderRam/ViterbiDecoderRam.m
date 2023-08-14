classdef ViterbiDecoderRam<hdlcommblks.internal.ViterbiDecoder

































    methods
        function this=ViterbiDecoderRam(block)












            supportedBlocks={...
            'commcnvcod2/Viterbi Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','RAM Implementation for Viterbi Decoder',...
            'HelpText','RAM Implementation for Viterbi Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'RAM-based Traceback'});
        end

    end

    methods
        tbdecNet=elabTraceback_decode(~,tbNet,blockInfo,dataRate)
        tbdecNet=elabTraceback_decodeL9(~,tbNet,blockInfo,dataRate)
        generateSLBlock(this,hC,targetBlkPath)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        ACSNet=elabACS(this,topNet,blockInfo,dataRate)
        normval=elabACSRenorm(~,ACSNet,sm,idx,idxType,thred,step,stmetType,stmetvType,dataRate)
        tbNet=elabRamTraceback(this,topNet,blockInfo,dataRate)
        tbctlNet=elabTraceback_control(~,tbNet,blockInfo,dataRate)
        nComp=elaborate(this,hN,hC)
        elaborateViterbiRamNetwork(this,topNet,blockInfo)
        blockInfo=getBlockInfo(this,hC)
        optimize=optimizeForModelGen(~,~,~)
    end

end

