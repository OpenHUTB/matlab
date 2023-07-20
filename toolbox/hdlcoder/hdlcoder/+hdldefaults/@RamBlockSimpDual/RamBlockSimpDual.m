classdef RamBlockSimpDual<hdlimplbase.EmlImplBase



    methods
        function this=RamBlockSimpDual(block)
            supportedBlocks={...
'hdlsllib/HDL RAMs/Simple Dual Port RAM'
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Simple dual-port RAM PIR instantiation',...
            'HelpText','Simple dual-port RAM Block code generation via PIR instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.RamBlockSimpDualHDLInstantiation');

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


