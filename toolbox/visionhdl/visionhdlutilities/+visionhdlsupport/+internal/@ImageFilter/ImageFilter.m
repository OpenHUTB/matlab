classdef ImageFilter<visionhdlsupport.internal.AbstractVHT










    methods
        function this=ImageFilter(block)

            supportedBlocks={...
            'visionhdlfilter/Image Filter',...
            'visionhdl.ImageFilter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Image Filter',...
            'HelpText','HDL Support for Image Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
