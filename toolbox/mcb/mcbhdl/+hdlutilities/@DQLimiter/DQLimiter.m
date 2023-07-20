classdef DQLimiter<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=DQLimiter(block)
            supportedBlocks={...
            'mcbcontrolslib/DQ Limiter',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for DQ Limiter Block',...
            'HelpText','HDL will be emitted for this DQ Limiter Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);
        end
    end

    methods
        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
    end

end