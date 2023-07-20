classdef DataTypePropagation<hdlimplbase.EmlImplBase



    methods
        function this=DataTypePropagation(block)
            supportedBlocks={...
            'simulink/Signal Attributes/Data Type Propagation',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Do not generate HDL and do not draw the block in generated model',...
            'HelpText','No HDL will be emitted for this block and Generated model will not have this block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'DataTypePropagation'},...
            'Description',desc);
        end
    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        registerImplParamInfo(this)
    end

    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        retval=usesSimulinkHandleForModelGen(~,~,~)
    end
end

