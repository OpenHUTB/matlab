classdef LineBuffer<visionhdlsupport.internal.AbstractVHT










    methods
        function this=LineBuffer(block)

            supportedBlocks={...
            'visionhdlutilities/Line Buffer',...
            'visionhdl.LineBuffer',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Line Buffer',...
            'HelpText','HDL Support for Line Buffer');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
