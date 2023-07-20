classdef NCO<dsphdlsupport.internal.AbstractDSPHDL







    methods
        function this=NCO(block)

            supportedBlocks={...
            'dsphdlsigops2/NCO',...
            'dsphdl.NCO'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for NCO',...
            'HelpText','HDL Support for NCO');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
