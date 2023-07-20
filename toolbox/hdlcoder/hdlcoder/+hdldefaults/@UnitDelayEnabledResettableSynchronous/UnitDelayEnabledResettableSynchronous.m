classdef UnitDelayEnabledResettableSynchronous<hdlimplbase.EmlImplBase



    methods
        function this=UnitDelayEnabledResettableSynchronous(block)
            supportedBlocks={...
'hdlsllib/Discrete/Unit Delay Enabled Resettable Synchronous'
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

        end
    end

    methods
        v_settings=block_validate_settings(~,~)
        udComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end
end
