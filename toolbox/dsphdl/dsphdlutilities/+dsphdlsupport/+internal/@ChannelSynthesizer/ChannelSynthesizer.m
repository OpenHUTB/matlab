classdef ChannelSynthesizer<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=ChannelSynthesizer(block)
            supportedBlocks={...
            'dsphdlfiltering2/Channel Synthesizer',...
'dsphdl.ChannelSynthesizer'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL support for Channel Synthesizer',...
            'HelpText','HDL support for Channel Synthesizer');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
