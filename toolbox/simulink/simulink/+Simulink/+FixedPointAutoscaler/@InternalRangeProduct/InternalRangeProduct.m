

classdef InternalRangeProduct<Simulink.FixedPointAutoscaler.InternalRange


    properties(Constant)
        OP_NONE=0;
        OP_DIV=1;
        OP_MUL=2;
    end

    methods(Access='public')

        function obj=InternalRangeProduct(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end
    end

    methods(Access='public')
        calcInternalRange(obj)
    end

    methods(Access='private')
        function ret=isElementWise(obj)
            ret=strcmp(obj.blockObject.Multiplication,'Element-wise(.*)');
        end



        operations=preprocessInputOperations(obj,inputOperationsStr)



        range=calcInverseRange(obj,inRange,inDim,isComplex)
    end
end