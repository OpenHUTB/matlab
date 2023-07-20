classdef SqrtTargetLibrary<hdlimplbase.EmlImplBase



    methods
        function this=SqrtTargetLibrary(block)
            supportedBlocks={...
            'built-in/Sqrt',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','SqrtTargetLibrary',...
            'Hidden',true);


        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
    end

end

