classdef PixelStreamFIFO<hdlimplbase.HDLRecurseIntoSubsystem










    methods
        function this=PixelStreamFIFO(block)

            supportedBlocks={...
            'visionhdlutilities/Pixel Stream FIFO',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Pixel Stream FIFO Block',...
            'HelpText','HDL will be emitted for the Pixel Stream FIFO block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');

        end
    end

end

