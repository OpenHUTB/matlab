classdef OFDMModulator<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=OFDMModulator(block)
            supportedBlocks={...
            'whdlmod/LTE OFDM Modulator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for LTE OFDM Modulator Block',...
            'HelpText','HDL will be emitted for the LTE OFDM Modulator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end