classdef CRCGenerator<hdlimplbase.EmlImplBase








    methods
        function this=CRCGenerator(block)
            supportedBlocks={...
'commhdl.internal.CRCGenerator'
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','General CRC Syndrome Generator HDL Optimized',...
            'HelpText','General CRC Syndrome Generator HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );
        end
    end
end