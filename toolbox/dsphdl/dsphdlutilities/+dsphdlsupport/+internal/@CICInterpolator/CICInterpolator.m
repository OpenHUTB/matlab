classdef CICInterpolator<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=CICInterpolator(block)

            supportedBlocks={...
            'dsphdlfiltering2/CIC Interpolator',...
'dsphdl.CICInterpolator'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for CIC Interpolator',...
            'HelpText','HDL Support for CIC Interpolator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
