classdef BiquadFilter<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=BiquadFilter(block)
            supportedBlocks={...
            'dsphdlfiltering2/Biquad Filter',...
'dsphdl.BiquadFilter'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Biquad Filter',...
            'HelpText','HDL Support for Biquad Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
