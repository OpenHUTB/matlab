classdef Closing<visionhdlsupport.internal.abstractMorph










    methods
        function this=Closing(block)

            supportedBlocks={...
            'visionhdlmorphops/Closing',...
'visionhdl.Closing'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Closing',...
            'HelpText','HDL Support for Closing');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
