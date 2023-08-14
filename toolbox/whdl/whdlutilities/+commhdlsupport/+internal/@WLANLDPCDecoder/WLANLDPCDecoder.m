

classdef WLANLDPCDecoder<hdlimplbase.EmlImplBase
    methods
        function this=WLANLDPCDecoder(block)
            supportedBlocks={...
            'whdledac/WLAN LDPC Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for WLAN LDPC Decoder',...
            'HelpText','HDL Support for WLAN LDPC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end