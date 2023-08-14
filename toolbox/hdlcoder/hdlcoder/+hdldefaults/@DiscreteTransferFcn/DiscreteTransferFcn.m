classdef DiscreteTransferFcn<hdlimplbase.EmlImplBase



    methods
        function this=DiscreteTransferFcn(block)
            supportedBlocks={...
            'built-in/DiscreteTransferFcn',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','');
        end
    end

    methods
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        [tfInfo,nfpOptions]=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        [ShFcatorRange,ShFactorCostMult]=findValidSharingFactorRangeAndCost(this,tfInfo)
    end

end

