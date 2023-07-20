classdef BitReduce<hdlimplbase.EmlImplBase



    methods
        function this=BitReduce(block)
            supportedBlocks={...
            'hdlsllib/Logic and Bit Operations/Bit Reduce',...
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
        hNewC=elaborate(this,hN,hC)
        v_settings=block_validate_settings(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end
end

