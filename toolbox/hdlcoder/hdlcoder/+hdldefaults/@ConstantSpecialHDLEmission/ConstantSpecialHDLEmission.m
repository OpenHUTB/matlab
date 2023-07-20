classdef ConstantSpecialHDLEmission<hdlimplbase.HDLDirectCodeGen



    methods
        function this=ConstantSpecialHDLEmission(block)
            supportedBlocks={...
            'built-in/Constant',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Constant Source Special (High Z) HDL emission',...
            'HelpText','Constant source special (High Z) code generation via direct HDL emission');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames','Logic Value');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hdlcode=emit(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end

end

