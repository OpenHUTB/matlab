classdef RamSystem<hdlimplbase.EmlImplBase



    methods
        function this=RamSystem(block)
            supportedBlocks={...
            'hdl.RAM',...
            'hdlsllib/HDL RAMs/Single Port RAM System',...
            'hdlsllib/HDL RAMs/Dual Port RAM System',...
            ['hdlsllib/HDL RAMs/Simple Dual',newline,'Port RAM System'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','MATLAB System',...
            'Deprecates',{});

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewInstance=elaborate(this,hN,hC)
        [RAMType,readNewData,IV,numBanks,RAMDirective]=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
        registerImplParamInfo(this)
    end

end

