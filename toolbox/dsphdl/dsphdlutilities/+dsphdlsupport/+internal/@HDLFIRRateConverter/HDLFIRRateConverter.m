classdef HDLFIRRateConverter<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=HDLFIRRateConverter(block)
            supportedBlocks={'dsphdlobslib/FIR Rate Converter'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Obsolete FIR Rate Conversion HDL Optimized',...
            'HelpText','HDL Support for Obsolete FIR Rate Conversion HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
