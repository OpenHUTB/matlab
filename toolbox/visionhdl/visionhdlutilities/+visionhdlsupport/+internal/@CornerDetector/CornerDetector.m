classdef CornerDetector<visionhdlsupport.internal.AbstractVHT










    methods
        function this=CornerDetector(block)

            supportedBlocks={...
            'visionhdlanalysis/Corner Detector',...
            'visionhdl.CornerDetector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Corner Detector',...
            'HelpText','HDL Support for Corner Detector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
