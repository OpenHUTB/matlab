classdef RamBlockDual<hdlimplbase.EmlImplBase



    methods
        function this=RamBlockDual(block)
            supportedBlocks={...
'hdlsllib/HDL RAMs/Dual Port RAM'
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Dual-port RAM PIR instantiation',...
            'HelpText','Dual-port RAM Block code generation via PIR instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.RamBlockDualHDLInstantiation');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewInstance=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateImplParams(this,hC)
        registerImplParamInfo(this)
    end

end

