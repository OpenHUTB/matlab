

classdef DVBS2SymbolModulator<hdlimplbase.EmlImplBase
    methods
        function this=DVBS2SymbolModulator(block)
            supportedBlocks={...
            'whdlmod/DVB-S2 Symbol Modulator',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for DVB-S2 Symbol Modulator',...
            'HelpText','HDL Support for DVB-S2 Symbol Modulator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end