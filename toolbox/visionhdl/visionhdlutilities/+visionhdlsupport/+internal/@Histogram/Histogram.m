classdef Histogram<visionhdlsupport.internal.AbstractVHT










    methods
        function this=Histogram(block)

            supportedBlocks={...
            'visionhdlstatistics/Histogram',...
            'visionhdl.Histogram',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Histogram',...
            'HelpText','HDL Support for Histogram');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
