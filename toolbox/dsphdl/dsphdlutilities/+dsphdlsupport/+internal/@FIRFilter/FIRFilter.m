classdef FIRFilter<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=FIRFilter(block)
            supportedBlocks={...
            'dsphdlfiltering2/Discrete FIR Filter',...
'dsphdl.FIRFilter'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Discrete FIR Filter',...
            'HelpText','HDL Support for Discrete FIR Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
