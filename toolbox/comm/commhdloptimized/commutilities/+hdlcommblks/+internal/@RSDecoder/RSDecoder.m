classdef RSDecoder<hdlcommblks.internal.AbstractCommHDL





























    methods
        function this=RSDecoder(block)












            supportedBlocks={...
            'commhdlblkcod/Integer-Output RS Decoder HDL Optimized',...
            'comm.HDLRSDecoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Reed-Solomon Decoder',...
            'HelpText','HDL Support for Reed-Solomon Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        nComp=elaborate(this,hN,hC)
        elaborateRSDecoderNetwork(this,topNet,blockInfo)
        blockInfo=getBlockInfo(this,hC)
        v=validateBlock(this,hC)
    end

end

