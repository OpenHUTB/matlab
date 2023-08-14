classdef ShiftAddMathArchitectures<hdlimplbase.EmlImplBase





    methods
        function this=ShiftAddMathArchitectures(block)
            supportedBlocks={...
            'built-in/Product',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ShiftAdd');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        impl=getFunctionImpl(this,hC)
        divideInfo=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
        v=validBlockMask(~,slbh)
        params=hideImplParams(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)

    end

end

