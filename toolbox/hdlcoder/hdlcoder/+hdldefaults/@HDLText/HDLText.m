classdef HDLText<hdlimplbase.EmlImplBase



    methods
        function this=HDLText(block)
            this@hdlimplbase.EmlImplBase();

            supportedBlocks={...
            ['simulink/Model-Wide',newline,'Utilities/DocBlock'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','HDLText',...
            'Deprecates',{});
        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        mainEarlyElaborate(this,hN,hC)
        val=mustElaborateInPhase1(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        flag=isMatchingBlock(this,blkh)
    end

end

