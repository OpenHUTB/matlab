classdef ComplexConjugate<hdlimplbase.EmlImplBase



    methods
        function this=ComplexConjugate(block)
            supportedBlocks={...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ComplexConjugate',...
            'Deprecates','hdldefaults.ComplexConjugateHDLEmission');


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

