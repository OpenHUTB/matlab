classdef ComplexToRealImag<hdlimplbase.EmlImplBase



    methods
        function this=ComplexToRealImag(block)
            supportedBlocks={...
            'built-in/ComplexToRealImag',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.ComplexToRealImagHDLEmission');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        opType=getBlockInfo(this,hC)
    end

end

