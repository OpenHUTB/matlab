

classdef PolarEncoder<hdlimplbase.HDLRecurseIntoSubsystem
    methods
        function this=PolarEncoder(block)
            supportedBlocks={...
            'whdledac/NR Polar Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Generate HDL Code for Polar Encoder Block',...
            'HelpText','HDL will be emitted for the Polar Encoder block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end
