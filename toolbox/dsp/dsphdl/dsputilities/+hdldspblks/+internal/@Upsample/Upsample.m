classdef Upsample<hdlimplbase.EmlImplBase




    methods
        function this=Upsample(block)

            supportedBlocks={...
            'dspsigops/Upsample',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL for Upsample Block',...
            'HelpText','HDL for Upsample Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.UpsampleHDLEmission','hdldefaults.Upsample'});

        end
    end

end
