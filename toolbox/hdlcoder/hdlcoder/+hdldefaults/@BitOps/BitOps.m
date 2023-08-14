classdef BitOps<hdlimplbase.EmlImplBase



    methods
        function this=BitOps(block)
            supportedBlocks={...
            'simulink/Logic and Bit Operations/Bitwise Operator',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.BitOpsHDLEmission');

        end

    end

    methods
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

