

classdef DVBS2BCHDecoder<hdlimplbase.EmlImplBase
    methods
        function this=DVBS2BCHDecoder(block)
            supportedBlocks={...
            'whdledac/DVB-S2 BCH Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for DVBS2 BCH Decoder',...
            'HelpText','HDL Support for DVBS2 BCH Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end

