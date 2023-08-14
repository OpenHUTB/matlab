classdef FIRRateConverter<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=FIRRateConverter(block)
            supportedBlocks={...
            'dsphdlfiltering2/FIR Rate Converter',...
'dsphdl.FIRRateConverter'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for FIR Rate Converter',...
            'HelpText','HDL Support for FIR Rate Converter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
