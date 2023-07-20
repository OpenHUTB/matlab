classdef IFFT<dsphdlsupport.internal.AbstractFFT





    methods
        function this=IFFT(block)
            supportedBlocks={...
            'dsphdlxfrm2/IFFT',...
'dsphdl.IFFT'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for IFFT',...
            'HelpText','HDL Support for IFFT');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
