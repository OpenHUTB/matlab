classdef RSEncoder<hdlcommblks.internal.AbstractCommHDL





























    methods
        function this=RSEncoder(block)












            supportedBlocks={...
            'commhdlblkcod/Integer-Input RS Encoder HDL Optimized',...
            'comm.HDLRSEncoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Reed-Solomon Encoder',...
            'HelpText','HDL Support for Reed-Solomon Encoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        nComp=elaborate(this,hN,hC)
        elaborateRSEncoderNetwork(this,topNet,blockInfo)
        blockInfo=getBlockInfo(this,hC)
        v=validateBlock(this,hC)
    end

end

