classdef UnitDelayResettable<hdlimplbase.EmlImplBase



    methods
        function this=UnitDelayResettable(block)
            supportedBlocks={...
'simulink_need_slupdate/Unit Delay Resettable'
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end
end
