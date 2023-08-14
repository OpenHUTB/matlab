classdef TrigonometricFunction<hdlimplbase.EmlImplBase




    methods
        function this=TrigonometricFunction(block)
            supportedBlocks={...
            'built-in/Trigonometry',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Trigonometric');

        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        impl=getFunctionImpl(this,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        stateInfo=getStateInfo(this,~)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validate(this,hC)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        hNewC=preElab(this,hN,hC)



    end

end

