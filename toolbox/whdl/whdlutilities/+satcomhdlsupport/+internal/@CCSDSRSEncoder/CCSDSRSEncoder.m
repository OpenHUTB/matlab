classdef CCSDSRSEncoder<hdlimplbase.EmlImplBase





    methods
        function this=CCSDSRSEncoder(block)

            supportedBlocks={...
            'whdledac/CCSDS RS Encoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for CCSDS Reed-Solomon Encoder',...
            'HelpText','HDL Support for CCSDS Reed-Solomon Encoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end