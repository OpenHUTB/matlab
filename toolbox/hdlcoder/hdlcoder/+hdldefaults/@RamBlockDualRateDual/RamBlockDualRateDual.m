classdef RamBlockDualRateDual<hdlimplbase.EmlImplBase



    methods
        function this=RamBlockDualRateDual(block)
            supportedBlocks={...
'hdlsllib/HDL RAMs/Dual Rate Dual Port RAM'
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Dual-rate Dual-port RAM PIR instantiation',...
            'HelpText','Dual-rate Dual-port RAM Block code generation via PIR instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewInstance=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(~,hC)
        v=validateImplParams(this,hC)
    end

end

