classdef CCSDSLDPCDecoder<hdlimplbase.EmlImplBase





    methods
        function this=CCSDSLDPCDecoder(block)

            supportedBlocks={...
            'whdledac/CCSDS LDPC Decoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for CCSDS LDPC Decoder',...
            'HelpText','HDL Support for CCSDS LDPC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end


