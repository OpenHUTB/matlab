classdef MultiPortSwitch<hdlimplbase.EmlImplBase



    methods
        function this=MultiPortSwitch(block)
            supportedBlocks={...
            'built-in/MultiPortSwitch',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.MultiPortSwitchHDLEmission');


        end

    end

    methods
        newComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        [inputmode,rndMode,satMode,dataPortOrder,portIndices,dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle]=getBlockInfo(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

