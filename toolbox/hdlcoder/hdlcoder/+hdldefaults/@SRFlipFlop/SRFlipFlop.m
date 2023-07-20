classdef SRFlipFlop<hdlimplbase.EmlImplBase





    methods
        function this=SRFlipFlop(block)
            supportedBlocks={...
'simulink_extras/Flip Flops/S-R Flip-Flop'...
            };
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        SRFlipFlopComp=elaborate(this,hN,hC)
        v_settings=block_validate_settings(this,hC)
    end

    methods(Hidden)
        initialQ=getBlockInfo(this,hC)
    end
end
