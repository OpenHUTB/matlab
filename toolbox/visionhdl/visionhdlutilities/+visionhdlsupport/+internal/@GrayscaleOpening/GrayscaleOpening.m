classdef GrayscaleOpening<visionhdlsupport.internal.AbstractVHT










    methods
        function this=GrayscaleOpening(block)

            supportedBlocks={...
            'visionhdlmorphops/Grayscale Opening',...
'visionhdl.GrayscaleOpening'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Grayscale Opening',...
            'HelpText','HDL Support for Grayscale Opening');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
