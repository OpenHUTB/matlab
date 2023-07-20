classdef ReciprocalRsqrtBasedNewtonSingleRate<hdlimplbase.EmlImplBase



    methods
        function this=ReciprocalRsqrtBasedNewtonSingleRate(block)
            supportedBlocks={...
            'built-in/Math',...
'built-in/Product'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ReciprocalRsqrtBasedNewtonSingleRate',...
            'DeprecatedArchName','RecipNewtonSingleRate',...
            'Deprecates','hdldefaults.RecipNewtonSingleRate');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        newtonInfo=getBlockInfo(this,slbh)
        choice=getChoice(this)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(~,hC)
        v=validateImplParams(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
    end

end

