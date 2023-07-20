

classdef InternalRangeDotProduct<Simulink.FixedPointAutoscaler.InternalRange


    methods(Access='public')

        function obj=InternalRangeDotProduct(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end
    end

    methods(Access='private')
        function range=invertRange(~,inRange)

            for idx=1:size(inRange,1)
                range=inRange(idx,:)*-1;
                inRange(idx,:)=[min(range),max(range)];
            end
        end

        function range=conjugateRange(obj,inRange,isComplex)


            if(isComplex)
                range=obj.unionRange(inRange,obj.invertRange(inRange));
            else
                range=inRange;
            end
        end
    end

    methods(Access='public')
        function calcInternalRange(obj)
            inDim=obj.getInputConnectedDims();
            inComplexity=obj.getInputConnectedComplexity();

            isComplex=inComplexity{1}||inComplexity{2};
            if obj.isScalar(inDim{1})&&~isComplex
                return;
            end

            inRange=obj.getInputConnectedRanges();

            conjRange=obj.conjugateRange(inRange{1},inComplexity{1});
            elementRange=obj.calcMultiplyRange(conjRange,inRange{2},isComplex);

            assert(numberOfElements(inDim{1})==numberOfElements(inDim{2}));
            n=numberOfElements(inDim{1});

            outRange=elementRange;
            for idx=1:(n-1)
                outRange=obj.unionRange(outRange,obj.calcAddRange(outRange,elementRange));
            end

            outRange=obj.unionRange(outRange,inRange{1},inRange{2});
            obj.putRange(outRange);
        end
    end
end

function n=numberOfElements(dim)
    assert(numel(dim)>1);
    n=prod(dim(2:end));
end
