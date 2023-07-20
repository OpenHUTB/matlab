

classdef PolarDecoder<hdlimplbase.EmlImplBase
    methods
        function this=PolarDecoder(block)
            supportedBlocks={...
            'whdledac/NR Polar Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for NR Polar Decoder',...
            'HelpText','HDL Support for NR Polar Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end