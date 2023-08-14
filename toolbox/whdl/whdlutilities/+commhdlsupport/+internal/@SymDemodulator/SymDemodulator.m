

classdef SymDemodulator<hdlimplbase.EmlImplBase
    methods
        function this=SymDemodulator(block)
            supportedBlocks={...
            'whdlmod/Symbol Demodulator',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Symbol Demodulator',...
            'HelpText','HDL Support for Symbol Demodulator');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end