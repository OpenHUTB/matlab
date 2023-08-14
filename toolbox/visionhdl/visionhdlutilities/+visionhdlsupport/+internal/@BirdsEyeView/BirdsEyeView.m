classdef BirdsEyeView<visionhdlsupport.internal.AbstractVHT










    methods
        function this=BirdsEyeView(block)

            supportedBlocks={...
            'visionhdlgeotforms/Birds-Eye View',...
'visionhdl.BirdsEyeView'...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','HDL Support for Birds-Eye View',...
            'HelpText','HDL Support for Birds-Eye View');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end

