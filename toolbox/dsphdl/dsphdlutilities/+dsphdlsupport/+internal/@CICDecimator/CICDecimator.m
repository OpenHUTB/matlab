classdef CICDecimator<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=CICDecimator(block)

            supportedBlocks={...
            'dsphdlfiltering2/CIC Decimator',...
'dsphdl.CICDecimator'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for CIC Decimator',...
            'HelpText','HDL Support for CIC Decimator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
