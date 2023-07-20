classdef ParkTransform<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=ParkTransform(block)
            supportedBlocks={...
            'mcbcontrolslib/Park Transform',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Park Transform Block',...
            'HelpText','HDL will be emitted for this Park Transform Block');

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