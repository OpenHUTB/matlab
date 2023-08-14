classdef ShiftAddMathArchitecturesDivRec<hdldefaults.ShiftAddMathArchitectures





    methods
        function this=ShiftAddMathArchitecturesDivRec(block)
            supportedBlocks={...
            'built-in/Product',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ShiftAdd');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        divideInfo=getBlockInfo(this,hC)
        v=validateBlock(this,hC)
        v=validBlockMask(~,slbh)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
    end

end

