classdef SignalSpecification<hdlimplbase.EmlImplBase



    methods
        function this=SignalSpecification(block)
            supportedBlocks={...
            'built-in/SignalSpecification',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Signal Specification Implementation',...
            'HelpText','SignalSpecification');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.SignalSpecificationHDLEmission'});
        end

    end

    methods
        newComp=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(~,hC)
    end

end

