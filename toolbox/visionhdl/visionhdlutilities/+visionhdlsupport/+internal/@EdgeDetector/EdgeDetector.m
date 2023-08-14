classdef EdgeDetector<visionhdlsupport.internal.AbstractVHT










    methods
        function this=EdgeDetector(block)

            supportedBlocks={...
            'visionhdlanalysis/Edge Detector',...
            'visionhdl.EdgeDetector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Edge Detector',...
            'HelpText','HDL Support for Edge Detector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
