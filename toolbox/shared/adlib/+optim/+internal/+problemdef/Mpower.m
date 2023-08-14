classdef Mpower<optim.internal.problemdef.operator.PowerOperator








    properties(Hidden,Constant)
        OperatorStr="^";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

        MpowerVersion=2;
    end

    methods(Access=public)

        function op=Mpower(obj,b)
            op=op@optim.internal.problemdef.operator.PowerOperator(obj,b);
        end

        function isAD=supportsAD(op,evalVisitor)
            if nargin<2


                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
            end
            b=getExponent(op,evalVisitor);

            isExponentInteger=b==floor(b);
            isExponentPositive=b>=0;
            isAD=isExponentInteger&&isExponentPositive;
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorMpower(visitor,op,Node);
        end


        function val=evaluate(op,Left,~,evalVisitor)
            val=Left^getExponent(op,evalVisitor);
        end

    end


    methods(Access=protected)



        function ok=checkIsValid(op,Left,b)

            checkIsValid@optim.internal.problemdef.operator.PowerOperator(op,Left,b);


            LeftSize=getSize(Left);
            invalid=(numel(LeftSize)>2)||~(LeftSize(1)==LeftSize(2));

            if invalid
                throwAsCaller(MException(message('shared_adlib:operators:MatrixMustBeSquare')));
            end
            ok=true;
        end
    end

end
