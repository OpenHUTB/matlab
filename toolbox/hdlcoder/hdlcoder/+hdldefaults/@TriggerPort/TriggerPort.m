classdef TriggerPort<hdlimplbase.PortBase



    methods
        function this=TriggerPort(block)
            supportedBlocks={...
            'built-in/TriggerPort',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the Trigger Block',...
            'HelpText','Supports the trigger block by modifying the network that owns the port.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

