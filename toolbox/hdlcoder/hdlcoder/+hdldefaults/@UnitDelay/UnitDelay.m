classdef UnitDelay<hdlimplbase.EmlImplBase



    methods
        function this=UnitDelay(block)
            supportedBlocks={...
            'built-in/UnitDelay',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates',{'hdldefaults.UnitDelayHDLEmission','hdldefaults.UnitDelayRTW'});
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
