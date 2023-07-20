classdef MatrixOperator<optim.internal.problemdef.Operator





    properties(Hidden=true)

        LeftSize=[0,0]

        RightSize=[0,0]

        IsLeftNumeric=false

        IsRightNumeric=false
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        MatrixOperatorVersion=1;
    end

    methods

        function op=MatrixOperator(Left,Right)

            op.IsLeftNumeric=getExprType(Left)==optim.internal.problemdef.ImplType.Numeric;
            op.IsRightNumeric=getExprType(Right)==optim.internal.problemdef.ImplType.Numeric;

            op.LeftSize=getSize(Left);
            op.RightSize=getSize(Right);

            checkIsValid(op,Left,Right);
        end
    end

end
