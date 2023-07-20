classdef OFDMEqualizer<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=OFDMEqualizer(block)

            supportedBlocks={...
            'whdlmod/OFDM Equalizer',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for OFDM Equalizer',...
            'HelpText','HDL will be emitted for the OFDM Equalizer');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end