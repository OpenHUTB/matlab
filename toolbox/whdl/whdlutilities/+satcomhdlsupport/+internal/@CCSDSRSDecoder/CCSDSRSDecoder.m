classdef CCSDSRSDecoder<hdlimplbase.EmlImplBase





    methods
        function this=CCSDSRSDecoder(block)

            supportedBlocks={...
            'whdledac/CCSDS RS Decoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for CCSDS Reed-Solomon Decoder',...
            'HelpText','HDL Support for CCSDS Reed-Solomon Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end