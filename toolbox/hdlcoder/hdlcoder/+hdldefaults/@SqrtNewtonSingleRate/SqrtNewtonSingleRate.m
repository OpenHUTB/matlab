classdef SqrtNewtonSingleRate<hdlimplbase.EmlImplBase



    methods
        function this=SqrtNewtonSingleRate(block)
            supportedBlocks={...
            'built-in/Sqrt',...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','SqrtNewtonSingleRate',...
            'Deprecates','hdldefaults.SqrtNewtonHDLEmission');

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
        v=validateBlock(this,hC)
        v=validateImplParams(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

