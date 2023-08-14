classdef OutputPort<hdldefaults.AbstractPort




    methods
        function this=OutputPort(block)
            supportedBlocks={...
            'built-in/Outport',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Support for the Output port Block',...
            'HelpText','Supports the Output port block in Simulink.');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

end

