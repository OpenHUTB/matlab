classdef CRCEncoder<commhdlsupport.internal.abstractCRC











    methods
        function this=CRCEncoder(block)

            supportedBlocks={...
            'whdledac/LTE CRC Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for LTE CRC Encoder',...
            'HelpText','HDL Support for LTE CRC Encoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end
    end
end