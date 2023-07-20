classdef DeratingFunction<hdlimplbase.HDLRecurseIntoSubsystem





    methods
        function this=DeratingFunction(block)
            supportedBlocks={...
            'mcbcontrolslib/Derating Function',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Derating Function Block',...
            'HelpText','HDL will be emitted for this Derating Function Block');

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