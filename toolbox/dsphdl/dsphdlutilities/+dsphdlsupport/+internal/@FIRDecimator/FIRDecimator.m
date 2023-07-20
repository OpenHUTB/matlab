classdef FIRDecimator<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=FIRDecimator(block)
            supportedBlocks={...
            'dsphdlfiltering2/FIR Decimator',...
'dsphdl.FIRDecimator'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for FIR Decimator',...
            'HelpText','HDL Support for FIR Decimator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
