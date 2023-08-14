classdef Downsampler<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=Downsampler(block)

            supportedBlocks={...
            'dsphdlsigops2/Downsampler',...
'dsphdl.Downsampler'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Downsampler',...
            'HelpText','HDL Support for Downsampler');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
