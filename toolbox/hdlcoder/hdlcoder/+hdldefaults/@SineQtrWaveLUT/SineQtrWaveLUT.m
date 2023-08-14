classdef SineQtrWaveLUT<hdlimplbase.HDLRecurseIntoSubsystem



    properties

        AllowedModes={'sin(2*pi*u)','cos(2*pi*u)','sin(2*pi*u) and cos(2*pi*u)','exp(i*2*pi*u)'};
    end


    methods
        function this=SineQtrWaveLUT(block)





            this.SuppressValidation=true;


            supportedBlocks={...
            ['simulink/Lookup',newline,'Tables/Sine'],...
            ['simulink/Lookup',newline,'Tables/Cosine'],...
            ['hdlsllib/Lookup',newline,'Tables/Sine',newline,'HDL Optimized'],...
            ['hdlsllib/Lookup',newline,'Tables/Cosine',newline,'HDL Optimized'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','default');
        end

    end

    methods
    end

    methods
        v_settings=block_validate_settings(this,hC)
        refRate=getReferenceRateForConstantBlocks(this,hN,hC)
        validateNetworkPostConstruction(~,hChildNetwork,~,hdlDriver)
    end


    methods(Hidden)
        v=validateBlock(~,hC)
    end

end


