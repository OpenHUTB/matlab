classdef GrayscaleErosion<visionhdlsupport.internal.AbstractVHT










    methods
        function this=GrayscaleErosion(block)

            supportedBlocks={...
            'visionhdlmorphops/Grayscale Erosion',...
'visionhdl.GrayscaleErosion'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Grayscale Erosion',...
            'HelpText','HDL Support for Grayscale Erosion');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
