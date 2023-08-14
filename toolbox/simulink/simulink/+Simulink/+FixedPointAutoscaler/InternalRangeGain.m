

classdef InternalRangeGain<Simulink.FixedPointAutoscaler.InternalRange


    methods(Access='public')

        function obj=InternalRangeGain(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end
    end

    methods(Access='private')
        function[range,dim,complexity]=getGainRangeDimAndComplexity(obj)



            dim=obj.getParameterDim(obj.blockObject.Gain);
            complexity=obj.getParameterComplexity(obj.blockObject.Gain);
            range=obj.getParameterRange('Gain',...
            obj.blockObject.paramMin,obj.blockObject.paramMax);
        end
    end

    methods(Access='public')
        function calcInternalRange(obj)
            inDim=obj.getInputConnectedDims();
            assert(length(inDim)==1);
            inComplexity=obj.getInputConnectedComplexity();
            assert(length(inComplexity)==1);
            [gainRange,gainDim,gainComplexity]=obj.getGainRangeDimAndComplexity();

            if~shouldCalcInternalRange(obj,inComplexity{1},gainComplexity)
                return;
            end

            complexity=inComplexity{1}||gainComplexity;
            inRange=obj.getInputConnectedRanges();

            switch obj.blockObject.Multiplication
            case 'Element-wise(K.*u)'
                outRange=obj.calcMultiplyRange(inRange{1},gainRange,complexity);
            case 'Matrix(K*u)'
                [outRange,~]=obj.calcMxMulRange(obj,gainRange,gainDim,inRange{1},inDim{1},complexity);
            case 'Matrix(u*K)'
                [outRange,~]=obj.calcMxMulRange(obj,inRange{1},inDim{1},gainRange,gainDim,complexity);
            otherwise
                assert(strcmp('Matrix(K*u) (u vector)',obj.blockObject.Multiplication));
                newInDim=[1,gainDim(3)];
                [outRange,~]=obj.calcMxMulRange(obj,gainRange,gainDim,inRange{1},newInDim,complexity);
            end



            if(isInMatrixMode(obj))
                outRange=obj.unionRange(outRange,[0,0]);
            end

            outRange=obj.unionRange(inRange{1},gainRange,outRange);
            obj.putRange(outRange);
        end
    end
end

function ret=shouldCalcInternalRange(obj,inComplexity,gainComplexity)
    ret=isInMatrixMode(obj)||inComplexity||gainComplexity;
end

function ret=isInMatrixMode(obj)
    ret=~strcmp(obj.blockObject.Multiplication,'Element-wise(K.*u)');
end
