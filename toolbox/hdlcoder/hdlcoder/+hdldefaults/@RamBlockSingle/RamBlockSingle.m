classdef RamBlockSingle<hdlimplbase.EmlImplBase



    methods
        function this=RamBlockSingle(block)
            supportedBlocks={...
'hdlsllib/HDL RAMs/Single Port RAM'
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Single-port RAM PIR instantiation',...
            'HelpText','Single-port RAM Block code generation via PIR instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.RamBlockSingleHDLInstantiation');

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

