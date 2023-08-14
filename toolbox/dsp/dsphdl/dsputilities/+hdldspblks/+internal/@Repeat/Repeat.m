classdef Repeat<hdlimplbase.EmlImplBase








    methods
        function this=Repeat(block)

            supportedBlocks={...
            'dspsigops/Repeat',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Repeat Block',...
            'HelpText','HDL Support for Repeat Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
