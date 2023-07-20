classdef VariableSelector<hdlimplbase.EmlImplBase




    methods
        function this=VariableSelector(block)

            supportedBlocks={...
            'dspindex/Variable Selector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL support for DSP Variable Selector',...
            'HelpText','HDL support for DSP Variable Selector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.VariableSelectorHDLEmission','hdldefaults.VariableSelector'});

        end
    end
end
