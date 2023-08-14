classdef WrapToZero<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=WrapToZero(block)
            supportedBlocks={...
            'simulink/Discontinuities/Wrap To Zero',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Wrap To Zero Block',...
            'HelpText','HDL will be emitted for this Wrap To Zero-block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
    end


    methods(Hidden)
        v=validateBlock(~,hC)
    end

end

