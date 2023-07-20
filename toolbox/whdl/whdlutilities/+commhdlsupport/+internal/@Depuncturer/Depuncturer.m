classdef Depuncturer<hdlimplbase.EmlImplBase






    methods
        function this=Depuncturer(block)
            supportedBlocks={...
            'whdledac/Depuncturer',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Depuncturer',...
            'HelpText','HDL Support for Depuncturer');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end