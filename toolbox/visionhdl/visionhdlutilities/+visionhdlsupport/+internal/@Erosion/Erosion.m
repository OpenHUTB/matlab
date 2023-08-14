classdef Erosion<visionhdlsupport.internal.abstractMorph










    methods
        function this=Erosion(block)

            supportedBlocks={...
            'visionhdlmorphops/Erosion',...
'visionhdl.Erosion'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Erosion',...
            'HelpText','HDL Support for Erosion');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
