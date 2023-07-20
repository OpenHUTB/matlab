classdef ROISelector<visionhdlsupport.internal.AbstractVHT










    methods
        function this=ROISelector(block)

            supportedBlocks={...
            'visionhdlutilities/ROI Selector',...
            'visionhdl.ROISelector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for ROI Selector',...
            'HelpText','HDL Support for ROI Selector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end

