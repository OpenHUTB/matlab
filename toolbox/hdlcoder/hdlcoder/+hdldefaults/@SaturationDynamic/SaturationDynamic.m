classdef SaturationDynamic<hdlimplbase.EmlImplBase



    methods
        function this=SaturationDynamic(block)
            supportedBlocks={...
            ['simulink/Discontinuities/Saturation',newline,'Dynamic'],...
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
        v=validateBlock(~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        [rndMode,satMode]=getBlockInfo(this,hC)
    end

end

