classdef ConvEncoder<hdlcommblks.internal.AbstractCommHDL





























    methods
        function this=ConvEncoder(block)












            supportedBlocks={...
            'commcnvcod2/Convolutional Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Convolutional Encoder',...
            'HelpText','HDL Support for Convolutional Encoder');

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
        dins=demuxSignal(~,hN,inSignal,sname)
        nComp=elaborate(this,hN,hC)
        elaborateConvEncoderNetwork(this,topNet,blockInfo)
        blockInfo=getBlockInfo(~,hC)
        blockInfo=getSysObjInfo(~,sysObj)
        v=validateBlock(this,hC)
    end

end

