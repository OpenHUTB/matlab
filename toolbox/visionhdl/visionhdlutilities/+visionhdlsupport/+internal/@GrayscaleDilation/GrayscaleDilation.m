classdef GrayscaleDilation<visionhdlsupport.internal.AbstractVHT










    methods
        function this=GrayscaleDilation(block)

            supportedBlocks={...
            'visionhdlmorphops/Grayscale Dilation',...
'visionhdl.GrayscaleDilation'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Grayscale Dilation',...
            'HelpText','HDL Support for Grayscale Dilation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
