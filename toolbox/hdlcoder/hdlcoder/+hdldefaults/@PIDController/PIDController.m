classdef PIDController<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=PIDController(block)
            supportedBlocks={...
            'simulink/Discrete/Discrete PID Controller',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for PID Controller Block',...
            'HelpText','HDL will be emitted for this PID Controller-block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        validateNetworkPostConstruction(this,hChildNetwork,hNICComp,hdlDriver)
    end

end

