classdef SqrtFunction<hdlimplbase.EmlImplBase



    methods
        function this=SqrtFunction(block)
            supportedBlocks={...
            'built-in/Sqrt',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','SqrtFunction',...
            'Deprecates','SqrtBitset');

        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        generateSLBlock(this,hC,targetBlkPath)
        impl=getFunctionImpl(this,hC)
        stateInfo=getStateInfo(this,hC)
        sqrtInfo=getBlockInfo(this,slbh)
        registerImplParamInfo(this)
        choice=getChoice(this)
        v=validBlockMask(~,slbh)
        v=validate(this,hC)
        v=validateImplParams(this,hC)
        val=allowDistributedPipelining(~,~)
        params=hideImplParams(~,~,~)

    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        latencyInfo=getLatencyInfo(this,hC)
        latencyInfo=SqrtBitsetLatency(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end


end

