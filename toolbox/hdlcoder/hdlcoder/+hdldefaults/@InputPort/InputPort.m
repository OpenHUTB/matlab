classdef InputPort<hdldefaults.AbstractPort




    methods
        function this=InputPort(block)
            supportedBlocks={...
            'built-in/Inport',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the Input port Block',...
            'HelpText','Supports the Input port block in Simulink.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        registerImplParamInfo(this)
        setPortImplParams(this,hPort,isTopNetworkPort)
    end

end

