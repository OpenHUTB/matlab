classdef Opening<visionhdlsupport.internal.abstractMorph










    methods
        function this=Opening(block)

            supportedBlocks={...
            'visionhdlmorphops/Opening',...
'visionhdl.Opening'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Opening',...
            'HelpText','HDL Support for Opening');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
