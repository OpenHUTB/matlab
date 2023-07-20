classdef FFT1536<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=FFT1536(block)
            supportedBlocks={...
            'whdlmod/FFT 1536',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for FFT 1536 Block',...
            'HelpText','HDL will be emitted for the FFT 1536 block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end