classdef BilateralFilter<visionhdlsupport.internal.AbstractVHT










    methods
        function this=BilateralFilter(block)

            supportedBlocks={...
            'visionhdlfilter/Bilateral Filter',...
            'visionhdl.BilateralFilter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Bilateral Filter',...
            'HelpText','HDL Support for Bilateral Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
