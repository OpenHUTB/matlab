classdef CoulombAndViscousFriction<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=CoulombAndViscousFriction(block)
            supportedBlocks={...
            ['simulink/Discontinuities/Coulomb &',newline,'Viscous Friction'],...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Coulomb & Viscous Friction Block',...
            'HelpText','HDL will be emitted for this Coulomb & Viscous Friction-block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v=validateBlock(~,hC)
    end

end
