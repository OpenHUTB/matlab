classdef GrayscaleClosing<visionhdlsupport.internal.AbstractVHT










    methods
        function this=GrayscaleClosing(block)

            supportedBlocks={...
            'visionhdlmorphops/Grayscale Closing',...
'visionhdl.GrayscaleClosing'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Grayscale Closing',...
            'HelpText','HDL Support for Grayscale Closing');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
