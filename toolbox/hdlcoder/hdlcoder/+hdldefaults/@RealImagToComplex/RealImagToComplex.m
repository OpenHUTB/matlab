classdef RealImagToComplex<hdlimplbase.EmlImplBase



    methods
        function this=RealImagToComplex(block)
            supportedBlocks={...
            'built-in/RealImagToComplex',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.RealImagToComplexHDLEmission');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
        [inputMode,cval]=getBlockInfo(this,hC)
    end

end

