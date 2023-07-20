classdef BitSet<hdlimplbase.EmlImplBase



    methods
        function this=BitSet(block)
            supportedBlocks={...
            'simulink/Logic and Bit Operations/Bit Set',...
            'simulink/Logic and Bit Operations/Bit Clear',...
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
        hNewC=elaborate(this,hN,hC)
        v_settings=block_validate_settings(this,hC)
        stateInfo=getStateInfo(this,hC)
    end

end

