classdef MathFunction<hdlimplbase.EmlImplBase



    methods
        function this=MathFunction(block)
            supportedBlocks={...
            'built-in/Math',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Math',...
            'Deprecates',{'hdldefaults.MathFunctionHDLEmission','SqrtBitset'});

        end

    end

    methods
        hNewC=elaborate(this,hN,blockComp)
        impl=getFunctionImpl(this,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validate(this,hC)
    end


    methods(Hidden)
        fixblkinhdllib(this,blkh)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        hNewC=preElab(this,hN,hC)
    end

end

