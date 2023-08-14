classdef ComplexToMagnitudeAngle<dsphdlsupport.internal.AbstractDSPHDL





    methods
        function this=ComplexToMagnitudeAngle(block)
            supportedBlocks={...
            'dsphdlmathfun2/Complex to Magnitude-Angle',...
'dsphdl.ComplexToMagnitudeAngle'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL support for Complex To Magnitude Angle',...
            'HelpText','HDL support for Complex To Magnitude Angle');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Linear',...
            'Description',desc);

        end
    end

end
