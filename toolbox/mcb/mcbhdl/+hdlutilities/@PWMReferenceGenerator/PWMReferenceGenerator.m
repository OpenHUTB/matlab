classdef PWMReferenceGenerator<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=PWMReferenceGenerator(block)
            supportedBlocks={...
            'mcbcontrolslib/PWM Reference Generator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for PWM Reference Block',...
            'HelpText','HDL will be emitted for this PWM Reference Block');

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