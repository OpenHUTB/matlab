classdef ColonExpressionImpl<optim.internal.problemdef.ExpressionImpl





    properties


Arguments

OptimArg
    end

    properties(Hidden)
        SupportsAD=true;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ColonExpressionImplVersion=1;
    end

    methods

        function obj=ColonExpressionImpl(first,step,last)
            [first,firstIsOptim]=optim.internal.problemdef.ColonExpressionImpl.checkAndWrapNumeric(first);
            [last,lastIsOptim]=optim.internal.problemdef.ColonExpressionImpl.checkAndWrapNumeric(last);
            if isequal(step,1)
                obj.Arguments={first,last};
                obj.OptimArg=[firstIsOptim,lastIsOptim];
            else
                [step,stepIsOptim]=optim.internal.problemdef.ColonExpressionImpl.checkAndWrapNumeric(step);
                obj.Arguments={first,step,last};
                obj.OptimArg=[firstIsOptim,stepIsOptim,lastIsOptim];
            end
            try



                EvalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
                val=getValue(obj,EvalVisitor);
                obj.Size=size(val);
            catch


                obj.Size=[];
            end
        end

    end


    methods


        function val=getValue(obj,evalVisitor)
            argVal=obj.Arguments;
            optimArg=obj.OptimArg;
            optimIdxVal=cellfun(@(arg)getArgValue(arg,evalVisitor),...
            argVal(optimArg),'UniformOutput',false);
            argVal(optimArg)=optimIdxVal;
            val=colon(argVal{:});

            function val=getArgValue(index,visitor)

                acceptVisitor(index,visitor);
                val=getValue(visitor);
            end
        end

        function depth=getDepth(obj)
            argVal=obj.Arguments;
            optimArg=obj.OptimArg;
            depth=cellfun(@(arg)arg.Depth,argVal(optimArg),'UniformOutput',true);

            depth=max(depth);
        end

    end

    methods(Hidden)


        function acceptVisitor(Node,visitor)
            visitColonExpressionImpl(visitor,Node);
        end

    end

    methods(Static,Access=protected)

        function[arg,optimArg]=checkAndWrapNumeric(arg)

            if~(isscalar(arg)||numel(arg)==0)
                throwAsCaller(MException(message('shared_adlib:operators:InputsMustBeScalar')));
            end
            if isa(arg,'optim.problemdef.OptimizationExpression')

                if~(getExprType(arg)==optim.internal.problemdef.ImplType.Numeric)
                    throwAsCaller(MException('shared_adlib:operators:nonNumericColon',...
                    getString(message('MATLAB:ErrorRecovery:UnsupportedOperator',...
                    ':','optim.problemdef.OptimizationExpression'))))
                end

                arg=forest2tree(getExprImpl(arg));
                optimArg=true;
            else
                if~(isnumeric(arg)||islogical(arg))||~isreal(arg)||isnan(arg)||~isfinite(arg)
                    throwAsCaller(MException(message('shared_adlib:operators:InvalidInput')));
                end
                optimArg=false;
            end
        end
    end

end
