classdef MultiportSelector<hdlimplbase.EmlImplBase




    methods
        function this=MultiportSelector(block)

            supportedBlocks={...
            'dspindex/Multiport Selector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL code generation for MultiportSelector',...
            'HelpText','HDL code generation for MultiportSelector');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.MultiportSelectorHDLEmission','hdldefaults.MultiportSelector'});

        end
    end

end
