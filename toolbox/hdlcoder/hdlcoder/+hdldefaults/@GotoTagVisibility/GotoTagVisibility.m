classdef GotoTagVisibility<hdlimplbase.EmlImplBase




    methods
        function this=GotoTagVisibility(block)
            supportedBlocks={...
            'built-in/GotoTagVisibility',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Goto Tag Visibility Block Implementation',...
            'HelpText','Goto Tag Visibility Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(this,hC)
        registerImplParamInfo(this);
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
    end

end
