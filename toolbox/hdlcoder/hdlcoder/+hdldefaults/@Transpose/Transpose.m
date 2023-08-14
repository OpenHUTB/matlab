classdef Transpose<hdlimplbase.EmlImplBase



    methods
        function this=Transpose(block)
            supportedBlocks={...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Transpose',...
            'Deprecates','hdldefaults.TransposeHDLEmission');


        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(~,hC)
    end

end

