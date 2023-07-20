classdef Channelizer<dsphdlsupport.internal.AbstractDSPHDL








    methods
        function this=Channelizer(block)
            supportedBlocks={...
            'dsphdlfiltering2/Channelizer',...
'dsphdl.Channelizer'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL support for Channelizer',...
            'HelpText','HDL support for Channelizer');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
