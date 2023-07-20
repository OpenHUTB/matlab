

classdef CRCEncoder<commhdlsupport.internal.abstractCRC
    methods
        function this=CRCEncoder(block)
            supportedBlocks={...
            'whdledac/NR CRC Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for NR CRC Encoder',...
            'HelpText','HDL Support for NR CRC Encoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end