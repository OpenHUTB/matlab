classdef ConvEncoder<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=ConvEncoder(block)

            supportedBlocks={...
            'whdledac/LTE Convolutional Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Convolutional Encoder Block',...
            'HelpText','HDL will be emitted for the Convolutional Encoder block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end