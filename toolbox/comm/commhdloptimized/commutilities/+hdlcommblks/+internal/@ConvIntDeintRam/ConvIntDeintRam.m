classdef ConvIntDeintRam<hdlcommblks.internal.AbstractCommHDL































    methods
        function this=ConvIntDeintRam(block)




            supportedBlocks={...
            'commcnvintrlv2/Convolutional Interleaver',...
'commcnvintrlv2/Convolutional Deinterleaver'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','RAM implementation for Conv Int & Deint blocks',...
            'HelpText','RAM implementation for Conv Int & Deint blocks');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'RAM'});

        end

    end

    methods
        nComp=elaborate(this,hN,hC)
        elaborateIntDeintRam(this,hN,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
    end

end

