classdef Dilation<visionhdlsupport.internal.abstractMorph










    methods
        function this=Dilation(block)

            supportedBlocks={...
            'visionhdlmorphops/Dilation',...
'visionhdl.Dilation'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Dilation',...
            'HelpText','HDL Support for Dilation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
