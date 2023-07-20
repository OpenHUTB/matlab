classdef StateControl<hdlimplbase.EmlImplBase



    methods
        function this=StateControl(block)
            supportedBlocks={...
            'built-in/StateControl',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the State Control Block',...
            'HelpText','Supports hardware-friendly semantics for a subsystem.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=validateBlock(this,hC)
    end

end

