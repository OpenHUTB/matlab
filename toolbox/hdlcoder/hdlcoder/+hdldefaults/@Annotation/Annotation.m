classdef Annotation<hdlimplbase.EmlImplBase



    methods
        function this=Annotation(block)
            supportedBlocks={...
            'simulink/Model-Wide Utilities/Model Info',...
            ['simulink/Model-Wide',newline,'Utilities/DocBlock'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Annotation',...
            'Deprecates',{'hdldefaults.AnnotationHDLEmission','hdldefaults.DocBlockHDLEmission'});

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        [isDoc,isMdlInfo]=getBlockInfo(this,hC)
        mainEarlyElaborate(this,hN,hC)
        mainElaborate(this,hN,hC)
        retval=usesSimulinkHandleForModelGen(this,hN,hC)
    end

end

