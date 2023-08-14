classdef ElectricalSystems<hdlimplbase.HDLRecurseIntoSubsystem





    methods
        function this=ElectricalSystems(block)
            supportedBlocks={...
            'mcbhdlplantlib/PMSM HDL',...
            'mcbhdlplantlib/Induction Motor HDL',...
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