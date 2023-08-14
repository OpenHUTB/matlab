

classdef APPDecoder<hdlimplbase.EmlImplBase
    methods
        function this=APPDecoder(block)
            supportedBlocks={...
            'whdledac/APP Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for APP Decoder',...
            'HelpText','HDL Support for APP Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end