

classdef CRCDecoder<commhdlsupport.internal.abstractCRC
    methods
        function this=CRCDecoder(block)
            supportedBlocks={...
            'whdledac/NR CRC Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for NR CRC Decoder',...
            'HelpText','HDL Support for NR CRC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end