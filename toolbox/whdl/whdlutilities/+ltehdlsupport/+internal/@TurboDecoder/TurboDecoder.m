classdef TurboDecoder<hdlimplbase.EmlImplBase







    methods
        function this=TurboDecoder(block)
            supportedBlocks={...
            'whdledac/LTE Turbo Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for LTE Turbo Decoder',...
            'HelpText','HDL Support for LTE Turbo Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end