classdef SineWave<hdlimplbase.EmlImplBase




    methods
        function this=SineWave(block)

            supportedBlocks={...
            'dspsrcs4/Sine Wave',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Sine Wave support',...
            'HelpText','Sine Wave HDL code generation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.SineWaveHDLEmission'});

        end
    end

end
