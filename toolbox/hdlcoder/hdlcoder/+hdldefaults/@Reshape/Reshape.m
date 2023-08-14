classdef Reshape<hdlimplbase.EmlImplBase



    methods
        function this=Reshape(block)
            supportedBlocks={...
            'built-in/Reshape',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.ReshapeHDLEmission');
        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        newComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        retval=usesSimulinkHandleForModelGen(this,hN,hC)
    end

end
