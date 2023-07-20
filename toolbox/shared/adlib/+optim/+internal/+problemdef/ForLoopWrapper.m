classdef ForLoopWrapper<optim.internal.problemdef.ExpressionImpl




    properties(Hidden=true)


LoopVar


LoopRange


LoopBody


LoopLevel


        MaxNumIter=0;
    end

    properties(Hidden)
        SupportsAD;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ForLoopWrapperVersion=1;
    end

    methods


        function obj=ForLoopWrapper(loopVarImpl,loopRange,loopBody,loopLevel)
            obj.LoopVar=loopVarImpl;
            obj.LoopRange=loopRange;
            obj.LoopBody=loopBody;
            obj.LoopLevel=loopLevel;
        end

        function depth=getDepth(obj)
            depth=getDepth(obj.LoopBody);
        end

        function setMaxNumIter(obj,numIter)



            obj.MaxNumIter=max(obj.MaxNumIter,numIter);
        end

        function maxNumIter=getMaxNumIter(obj)
            maxNumIter=obj.MaxNumIter;
        end

    end

    methods(Hidden)


        function acceptVisitor(obj,visitor)
            visitForLoopWrapper(visitor,obj);
        end

    end


    methods(Static)


        function rangeImpl=getLoopRange(loopRange)
            if~isa(loopRange,'optim.problemdef.OptimizationExpression')


                rangeImpl=optim.internal.problemdef.NumericExpressionImpl(loopRange);
            else


                rangeImpl=forest2tree(getExprImpl(loopRange));
                rangeImpl=rangeImpl.Root;
                if~(isa(rangeImpl,'optim.internal.problemdef.NumericExpressionImpl')||...
                    isa(rangeImpl,'optim.internal.problemdef.ColonExpressionImpl'))


                    throw(MException('optim:problemdef:cannotDependOnVar','Index cannot depend on optimvar'));
                end
            end
        end

    end

end
