classdef TurboEncoder<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=TurboEncoder(block)
            supportedBlocks={...
            'whdledac/LTE Turbo Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for LTE Turbo Encoder Block',...
            'HelpText','HDL will be emitted for the LTE Turbo Encoder block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end