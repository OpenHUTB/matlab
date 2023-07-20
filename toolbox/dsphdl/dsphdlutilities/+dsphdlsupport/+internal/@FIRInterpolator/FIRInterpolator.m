classdef FIRInterpolator<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=FIRInterpolator(block)
            supportedBlocks={...
            'dsphdlfiltering2/FIR Interpolator',...
'dsphdl.FIRInterpolator'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for FIR Interpolator',...
            'HelpText','HDL Support for FIR Interpolator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
