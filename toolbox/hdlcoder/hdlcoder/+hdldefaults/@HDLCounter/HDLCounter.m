classdef HDLCounter<hdlimplbase.EmlImplBase



    methods
        function this=HDLCounter(block)
            supportedBlocks={...
'hdlsllib/Sources/HDL Counter'
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.HDLCounterHDLEmission');

        end

    end

    methods
        CInfo=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        cntComp=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

