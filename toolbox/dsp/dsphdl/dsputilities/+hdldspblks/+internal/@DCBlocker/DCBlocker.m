classdef DCBlocker<imported.hdldefaults.SystemBlock




    methods
        function this=DCBlocker(block)
            supportedBlocks={...
'dspsigops/DC Blocker'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','DC Blocker',...
            'HelpText','DC Blocker');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );

        end
    end
end

