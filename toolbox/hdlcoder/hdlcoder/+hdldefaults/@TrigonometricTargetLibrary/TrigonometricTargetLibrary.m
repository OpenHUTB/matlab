classdef TrigonometricTargetLibrary<hdlimplbase.EmlImplBase



    methods
        function this=TrigonometricTargetLibrary(block)
            supportedBlocks={...
            'built-in/Trigonometry',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','TrigonometricTargetLibrary',...
            'Hidden',true);

        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

