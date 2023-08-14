classdef PixelControlBusCreator<hdlimplbase.HDLRecurseIntoSubsystem










    methods
        function this=PixelControlBusCreator(block)

            supportedBlocks={...
            'visionhdlutilities/Pixel Control Bus Creator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Pixel Control Bus Creator Block',...
            'HelpText','HDL will be emitted for this  Pixel Control Bus Creator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');

        end
    end

end

