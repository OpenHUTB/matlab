classdef RSDecoder<hdlimplbase.EmlImplBase





    methods
        function this=RSDecoder(block)

            supportedBlocks={...
            'whdledac/RS Decoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Reed-Solomon Decoder',...
            'HelpText','HDL Support for Reed-Solomon Decoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end