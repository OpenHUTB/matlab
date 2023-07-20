classdef LookupTable<visionhdlsupport.internal.AbstractVHT










    methods
        function this=LookupTable(block)

            supportedBlocks={...
            'visionhdlconversions/Lookup Table',...
            'visionhdl.LookupTable',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Lookup Table',...
            'HelpText','HDL Support for Lookup Table');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
