classdef CompareToZero<hdlimplbase.EmlImplBase



    methods
        function this=CompareToZero(block)
            supportedBlocks={...
            'simulink/Logic and Bit Operations/Compare To Zero',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.CompareToZeroHDLEmission');

        end

    end

    methods
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        v=validatePortDatatypes(this,hC)
    end

end

