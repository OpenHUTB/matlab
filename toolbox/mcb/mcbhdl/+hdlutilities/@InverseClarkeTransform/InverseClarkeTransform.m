classdef InverseClarkeTransform<hdlimplbase.HDLRecurseIntoSubsystem





    methods
        function this=InverseClarkeTransform(block)
            supportedBlocks={...
            'mcbcontrolslib/Inverse Clarke Transform',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Inverse Clarke Transform Block',...
            'HelpText','HDL will be emitted for this Inverse Clarke Transform Block');

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