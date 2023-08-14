classdef FarrowRateConverter<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=FarrowRateConverter(block)
            supportedBlocks={...
            'dsphdlsigops2/Farrow Rate Converter',...
'dsphdl.FarrowRateConverter'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Farrow Rate Converter',...
            'HelpText','HDL Support for Farrow Rate Converter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
