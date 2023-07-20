classdef RecipDiv<hdlimplbase.EmlImplBase



    methods
        function this=RecipDiv(block)
            supportedBlocks={...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Reciprocal',...
            'Deprecates','hdldefaults.RecipDivHDLEmission');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        newtonInfo=getBlockInfo(~,slbh)
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

