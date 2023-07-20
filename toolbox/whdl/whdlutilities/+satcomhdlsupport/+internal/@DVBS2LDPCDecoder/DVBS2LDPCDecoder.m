classdef DVBS2LDPCDecoder<hdlimplbase.EmlImplBase





    methods
        function this=DVBS2LDPCDecoder(block)

            supportedBlocks={...
            'whdledac/DVB-S2 LDPC Decoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for DVBS2 LDPC Decoder',...
            'HelpText','HDL Support for DVBS2 LDPC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end