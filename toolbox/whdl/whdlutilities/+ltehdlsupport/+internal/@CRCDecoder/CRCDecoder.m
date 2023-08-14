classdef CRCDecoder<commhdlsupport.internal.abstractCRC










    methods
        function this=CRCDecoder(block)
            supportedBlocks={...
'whdledac/LTE CRC Decoder'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for LTE CRC Decoder',...
            'HelpText','HDL Support for LTE CRC Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end
    end
end