classdef UnitDelayEnabled<hdlimplbase.EmlImplBase



    methods
        function this=UnitDelayEnabled(block)
            supportedBlocks={...
'simulink_need_slupdate/Unit Delay Enabled'
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.UnitDelayEnabledHDLEmission');

        end
    end

    methods
        udComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end
end
