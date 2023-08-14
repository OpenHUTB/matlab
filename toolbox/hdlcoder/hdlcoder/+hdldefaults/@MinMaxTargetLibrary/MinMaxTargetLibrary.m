classdef MinMaxTargetLibrary<hdlimplbase.EmlImplBase



    methods
        function this=MinMaxTargetLibrary(block)
            supportedBlocks={...
            'built-in/MinMax',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','MinMaxTargetLibrary',...
            'Hidden',true);

        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        hNewC=elaborateMain(this,hN,blockComp)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=validateBlock(this,hC)
    end

end

