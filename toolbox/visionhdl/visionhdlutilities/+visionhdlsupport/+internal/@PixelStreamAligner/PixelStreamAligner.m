classdef PixelStreamAligner<visionhdlsupport.internal.AbstractVHT










    methods
        function this=PixelStreamAligner(block)

            supportedBlocks={...
            'visionhdlutilities/Pixel Stream Aligner',...
            'visionhdl.PixelStreamAligner',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Pixel Stream Aligner',...
            'HelpText','HDL Support for Pixel Stream Aligner');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
