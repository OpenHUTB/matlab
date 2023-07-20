classdef DSPDelay<hdlimplbase.EmlImplBase




    methods
        function this=DSPDelay(block)

            supportedBlocks={...
            'dspobslib/Delay',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL for DSP Delay',...
            'HelpText','HDL for DSP Delay');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.DSPDelayHDLEmission','hdldefaults.DSPDelay'});

        end
    end

end
