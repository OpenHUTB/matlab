

classdef DVBS2SymbolDemodulator<hdlimplbase.EmlImplBase
    methods
        function this=DVBS2SymbolDemodulator(block)
            supportedBlocks={...
            'whdlmod/DVB-S2 Symbol Demodulator',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for DVB-S2 Symbol Demodulator',...
            'HelpText','HDL Support for DVB-S2 Symbol Demodulator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end