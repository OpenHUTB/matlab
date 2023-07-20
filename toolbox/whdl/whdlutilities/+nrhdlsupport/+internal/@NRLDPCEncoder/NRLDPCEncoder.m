classdef NRLDPCEncoder<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=NRLDPCEncoder(block)

            supportedBlocks={...
            'whdledac/NR LDPC Encoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for NR LDPC Encoder Block',...
            'HelpText','HDL will be emitted for the NR LDPC Encoder block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end