classdef Deserializer1D<hdlimplbase.EmlImplBase



    methods
        function this=Deserializer1D(block)
            supportedBlocks={...
'hdlsllib/HDL Operations/Deserializer1D'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block...
            );

        end

    end

    methods
        CInfo=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

