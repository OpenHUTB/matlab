classdef ColorSpaceConverter<visionhdlsupport.internal.AbstractVHT












    methods
        function this=ColorSpaceConverter(block)

            supportedBlocks={...
            'visionhdlconversions/Color Space Converter',...
            'visionhdl.ColorSpaceConverter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Color Space Converter',...
            'HelpText','HDL Support for Color Space Converter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
