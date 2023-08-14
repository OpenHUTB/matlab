classdef SpeedMeasurment<hdlimplbase.HDLRecurseIntoSubsystem







    methods
        function this=SpeedMeasurment(block)
            supportedBlocks={...
            'mcbpositiondecoderlib/Speed Measurement',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
    end

end