classdef Gamma<visionhdlsupport.internal.AbstractVHT










    methods
        function this=Gamma(block)

            supportedBlocks={...
            'visionhdlconversions/Gamma Corrector',...
'visionhdl.GammaCorrector'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Gamma Corrector',...
            'HelpText','HDL Support for Gamma Corrector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end
    end

end
