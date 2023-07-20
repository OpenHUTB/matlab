classdef MedianFilter<visionhdlsupport.internal.AbstractVHT










    methods
        function this=MedianFilter(block)

            supportedBlocks={...
            'visionhdlfilter/Median Filter',...
            'visionhdl.MedianFilter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Median Filter',...
            'HelpText','HDL Support for Median Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
