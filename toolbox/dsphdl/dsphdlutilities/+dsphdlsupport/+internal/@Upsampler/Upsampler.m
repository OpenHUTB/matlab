classdef Upsampler<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=Upsampler(block)

            supportedBlocks={...
            'dsphdlsigops2/Upsampler',...
'dsphdl.Upsampler'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Upsampler',...
            'HelpText','HDL Support for Upsampler');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end