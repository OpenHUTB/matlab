classdef CounterFreeRunning<hdlimplbase.EmlImplBase



    methods
        function this=CounterFreeRunning(block)
            supportedBlocks={...
            'simulink/Sources/Counter Free-Running',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.CounterFreeRunningHDLEmission');


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
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

