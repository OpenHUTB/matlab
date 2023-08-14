classdef PassThrough<hdlimplbase.EmlImplBase



    methods
        function this=PassThrough(block)
            supportedBlocks={...
            'dspsigattribs/Convert 1-D to 2-D',...
            'built-in/SignalConversion',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Inputs to outputs',...
            'HelpText','An implementation that connects all inputs to outputs');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.PassThroughHDLEmission'}...
            );
        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        newComp=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        retval=usesSimulinkHandleForModelGen(this,hN,hC)
    end

end

