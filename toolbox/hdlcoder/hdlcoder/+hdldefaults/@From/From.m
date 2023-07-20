classdef From<hdlimplbase.EmlImplBase



    methods
        function this=From(block)
            supportedBlocks={...
            'built-in/From',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','From Block Implementation',...
            'HelpText','From Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates','hdldefaults.FromBlock');

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        [tag,scope]=getTag(this,hC)
        val=mustElaborateInPhase1(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
        registerImplParamInfo(this)
    end

end

