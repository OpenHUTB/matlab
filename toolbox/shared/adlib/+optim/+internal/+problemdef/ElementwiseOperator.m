classdef ElementwiseOperator<optim.internal.problemdef.Operator





    properties(Hidden,SetAccess=private,GetAccess=public)
        ElementwiseOperatorVersion=1;
    end

    methods

        function op=ElementwiseOperator()
        end


        function outSize=getOutputSize(~,leftSz,rightSz,~)


            if all(leftSz==1)
                outSize=rightSz;
            else
                outSize=leftSz;
            end
        end

    end

    methods(Access=protected,Static)

        function ok=checkIsValid(Left,Right)
            optim.internal.problemdef.checkDimensionMatch(Left,Right);
            ok=true;
        end
    end

end
