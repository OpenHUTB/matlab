classdef EnablePort<hdlimplbase.EnablePortBase





    methods
        function this=EnablePort(block)
            supportedBlocks={...
            'built-in/EnablePort',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the Enable Block',...
            'HelpText','Supports the enable block by alternating the network that owns the port.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        ishwfr=isInHwFriendly(~,hC)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)

        function v=validateBlock(this,hC)
            v=baseValidateEnablePort(this,hC);
        end
    end

end

