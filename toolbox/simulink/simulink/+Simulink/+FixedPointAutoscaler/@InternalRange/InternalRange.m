


classdef InternalRange<handle





    properties(GetAccess='protected',SetAccess='private')




        runObj;
        allResults;
    end

    properties(GetAccess='protected',SetAccess='private')
        blockObject;
    end

    methods(Access='protected')














        putRange(obj,range)



        derivedRange=getDerivedRange(obj)



        inRanges=getInputConnectedRanges(obj)



        function inDims=getInputConnectedDims(obj)
            inDims=get_param(obj.blockObject.portHandles.Inport,'CompiledPortDimensions');
            if~iscell(inDims)
                inDims={inDims};
            end
        end



        function inComplexity=getInputConnectedComplexity(obj)
            inComplexity=get_param(obj.blockObject.portHandles.Inport,'CompiledPortComplexSignal');
            if~iscell(inComplexity)
                inComplexity={inComplexity};
            end
        end










        paramRange=getParameterRange(obj,parameterName,varargin);



        paramDim=getParameterDim(obj,parameterExpr);



        paramComplexity=getParameterComplexity(obj,parameterExpr);

    end

    methods(Access='protected',Static=true)

        outRange=calcMultiplyRange(inRangeOne,inRangeTwo,isComplex)
        outRange=calcDivideRange(inRangeOne,inRangeTwo,isComplex)
        outRange=calcSubtractRange(inRangeOne,inRangeTwo,isComplex)
        outRange=calcAddRange(inRangeOne,inRangeTwo,isComplex)
        outRange=calcSquareRange(inRange,isComplex)




        outRange=mergeRange(varargin)



        outRange=unionRange(varargin)



        outRange=intersectRange(inRangeOne,inRangeTwo)






        outRange=cartesianRange(inRangeOne,inRangeTwo,operatorFunction)





        ret=calcMultiRangeOp(opFunction,isComplex,inRange1,inRange2)



        [range,dim]=calcMxMulRange(obj,range1,dim1,range2,dim2,isComplex)


        function ret=isScalar(dim)
            ret=(prod(dim(2:end))==1);
        end


        function ret=isVector(dim)
            ret=(sum(dim(2:end)~=1)==1);
        end



        function len=vectorLength(dim)
            len=dim(find(dim(2:end)>1,1)+1);
        end
    end

    methods(Access='public')

        function obj=InternalRange(blockObject,runObj,allResults)
            obj.blockObject=blockObject;
            obj.runObj=runObj;
            obj.allResults=allResults;
        end

        function delete(obj)


            obj.blockObject=[];
            obj.runObj=[];
            obj.allResults=[];
        end
    end

    methods(Access='public',Abstract=true)



        calcInternalRange(obj)
    end

    methods(Access='public',Static=true)


        calcInternalRanges(model,runObj)
    end
end


