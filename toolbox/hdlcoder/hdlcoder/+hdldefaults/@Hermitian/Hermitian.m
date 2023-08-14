classdef Hermitian<hdlimplbase.EmlImplBase



    methods
        function this=Hermitian(block)
            supportedBlocks={...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Hermitian',...
            'Deprecates','hdldefaults.HermitianHDLEmission');



        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
    end

end

