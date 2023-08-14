classdef(Abstract)Operator




    properties(Hidden,SetAccess=private,GetAccess=public)
        OperatorVersion=1;
    end

    properties(Abstract,Hidden,Constant)
OperatorStr
    end

    methods(Abstract=true)

        acceptVisitor(Op,visitor,Node);





        outVal=evaluate(op,LeftVal,RightVal,evalVisitor);
    end

    methods








        function outSize=getOutputSize(~,LeftSz,~,~)
            outSize=LeftSz;
        end









        function outNames=getOutputIndexNames(~,~,~)
            outNames={{},{}};
        end








        function outType=getOutputType(~,LeftType,~,~)
            outType=LeftType;
        end








        function isAD=supportsAD(~,~)
            isAD=true;
        end



        function numParens=getOutputParens(~)
            numParens=1;
        end



        function[funStr,numParens]=buildNonlinearStr(op,~,...
            leftVarName,rightVarName,leftParens,rightParens)
            funStr="("+leftVarName+" "+op.OperatorStr+" "+rightVarName+")";
            numParens=leftParens+rightParens+1;
        end

    end

    methods(Access=protected,Abstract=true)



        ok=checkIsValid(op,Left,Right);
    end
end
