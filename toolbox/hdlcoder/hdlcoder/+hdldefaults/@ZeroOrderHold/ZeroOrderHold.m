classdef ZeroOrderHold<hdlimplbase.EmlImplBase



    methods
        function this=ZeroOrderHold(block)
            supportedBlocks={...
            'built-in/ZeroOrderHold',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.ZeroOrderHoldHDLEmission');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
    end

end

