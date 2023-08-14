

classdef LDPCDecoder<hdlimplbase.EmlImplBase
    methods
        function this=LDPCDecoder(block)
            supportedBlocks={...
            'whdledac/NR LDPC Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for NR LDPC Decoder',...
            'HelpText','HDL Support for NR LDPC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end