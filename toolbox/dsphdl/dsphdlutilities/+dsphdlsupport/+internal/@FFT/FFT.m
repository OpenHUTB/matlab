classdef FFT<dsphdlsupport.internal.AbstractFFT





    methods
        function this=FFT(block)
            supportedBlocks={...
            'dsphdlxfrm2/FFT',...
'dsphdl.FFT'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for FFT',...
            'HelpText','HDL Support for FFT');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
