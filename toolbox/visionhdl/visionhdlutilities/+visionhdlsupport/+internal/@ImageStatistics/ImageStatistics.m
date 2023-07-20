classdef ImageStatistics<visionhdlsupport.internal.AbstractVHT










    methods
        function this=ImageStatistics(block)

            supportedBlocks={...
            'visionhdlstatistics/Image Statistics',...
            'visionhdl.ImageStatistics',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Image Statistics',...
            'HelpText','HDL Support for Image Statistics');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
