classdef XilinxVivadoSystemGeneratorSubsystem<hdlimplbase.EmlImplBase



    methods
        function this=XilinxVivadoSystemGeneratorSubsystem(block)
            supportedBlocks={...
            'built-in/SubSystem',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','XilinxVivadoSystemGeneratorSubsystem',...
            'Hidden',true);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        xsgComp=elaborate(~,hN,hC)
        val=mustElaborateInPhase1(~,~,~)
    end

end

