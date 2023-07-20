classdef ResetPort<hdlimplbase.PortBase




    methods
        function this=ResetPort(block)
            supportedBlocks={...
            'built-in/ResetPort',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the Enable Block',...
            'HelpText','Supports the reset block by alternating the network that owns the port.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        ishwfr=isInHwFriendly(~,hC)
        v=validateBlock(this,hC)
        registerImplParamInfo(this);
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

