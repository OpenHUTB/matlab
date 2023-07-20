classdef SampleControlBusCreator<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=SampleControlBusCreator(block)

            supportedBlocks={...
            'whdlutilities/Sample Control Bus Creator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Sample Control Bus Creator Block',...
            'HelpText','HDL will be emitted for this Sample Control Bus Creator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end