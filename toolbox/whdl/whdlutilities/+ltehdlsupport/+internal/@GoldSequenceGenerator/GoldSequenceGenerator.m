classdef GoldSequenceGenerator<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=GoldSequenceGenerator(block)
            supportedBlocks={...
            'whdlutilities/LTE Gold Sequence Generator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for LTE Gold Sequence Generator Block',...
            'HelpText','HDL will be emitted for the LTE Gold Sequence Generator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end