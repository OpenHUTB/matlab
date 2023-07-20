classdef PosDecoderBlocks<hdlimplbase.HDLRecurseIntoSubsystem







    methods
        function this=PosDecoderBlocks(block)
            supportedBlocks={...
            'mcbpositiondecoderlib/Quadrature Decoder',...
            'mcbpositiondecoderlib/Mechanical to Electrical Position',...
            'mcbhdlpositiondecoderlib/Mechanical to Electrical Position',...
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