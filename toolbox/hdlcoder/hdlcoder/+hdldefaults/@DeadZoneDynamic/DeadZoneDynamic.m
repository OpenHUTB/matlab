classdef DeadZoneDynamic<hdlimplbase.EmlImplBase



    methods
        function this=DeadZoneDynamic(block)
            supportedBlocks={...
            ['simulink/Discontinuities/Dead Zone',newline,'Dynamic'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
    end

end

