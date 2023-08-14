classdef CounterLimited<hdlimplbase.EmlImplBase



    methods
        function this=CounterLimited(block)
            supportedBlocks={...
            'simulink/Sources/Counter Limited',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.CounterLimitedHDLEmission');


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,hC)
    end

end

