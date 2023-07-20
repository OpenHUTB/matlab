classdef CRCDetector<hdlimplbase.EmlImplBase








    methods
        function this=CRCDetector(block)

            supportedBlocks={...
'commhdl.internal.CRCDetector'
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','General CRC Syndrome Detector HDL Optimized',...
            'HelpText','General CRC Syndrome Detector HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end
    end
end