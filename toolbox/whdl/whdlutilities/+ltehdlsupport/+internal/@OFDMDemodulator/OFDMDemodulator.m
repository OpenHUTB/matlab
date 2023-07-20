classdef OFDMDemodulator<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=OFDMDemodulator(block)
            supportedBlocks={...
            'whdlmod/LTE OFDM Demodulator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for LTE OFDM Demodulator Block',...
            'HelpText','HDL will be emitted for the LTE OFDM Demodulator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end