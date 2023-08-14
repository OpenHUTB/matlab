classdef ConvolutionalEncoder<hdlimplbase.EmlImplBase






    methods
        function this=ConvolutionalEncoder(block)
            supportedBlocks={...
            'whdledac/Convolutional Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for ConvolutionalEncoder',...
            'HelpText','HDL Support for ConvolutionalEncoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end