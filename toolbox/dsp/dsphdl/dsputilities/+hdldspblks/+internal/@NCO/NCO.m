classdef NCO<hdlimplbase.EmlImplBase




    methods
        function this=NCO(block)

            supportedBlocks={...
            'dspsigops/NCO',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','NCO',...
            'HelpText','NCO code generation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.NCOHDLEmission'});

        end
    end

end
