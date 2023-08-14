classdef Memory<hdlimplbase.EmlImplBase



    methods
        function this=Memory(block)
            supportedBlocks={...
            'built-in/Memory',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.MemoryHDLEmission');



        end

    end

    methods
        udComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
        v=validateImplParams(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

