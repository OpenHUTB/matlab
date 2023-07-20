classdef Saturation<hdlimplbase.EmlImplBase



    methods
        function this=Saturation(block)
            supportedBlocks={...
            'built-in/Saturate',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.SaturationHDLEmission');

        end

    end

    methods
        [lowerLimit,upperLimit,rndMode,satMode]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

