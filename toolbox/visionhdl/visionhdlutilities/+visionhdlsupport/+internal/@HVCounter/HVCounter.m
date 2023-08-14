classdef HVCounter<visionhdlsupport.internal.AbstractVHT










    methods
        function this=HVCounter(block)

            supportedBlocks={...
            'visionhdlutilities/HV Counter',...
            'visionhdl.HVCounter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for HV Counter',...
            'HelpText','HDL Support for HV Counter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
