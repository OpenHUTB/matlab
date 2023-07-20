classdef Transpose<optim.internal.problemdef.Operator




    properties(SetAccess=protected,GetAccess=protected)

LeftSize
    end

    properties(Hidden,Constant)
        OperatorStr=".'";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

        TransposeVersion=2;
    end

    methods

        function op=Transpose(Left)

            checkIsValid(op,Left,[]);

            op.LeftSize=getSize(Left);
        end


        function outSize=getOutputSize(op,~,~,~)
            outSize=[op.LeftSize(2),op.LeftSize(1)];
        end


        function numParens=getOutputParens(~)


            numParens=1;
        end


        function newIdx=getLinearIdx(op)


            newIdx=1:prod(op.LeftSize);
            newIdx=reshape(newIdx,op.LeftSize);
            newIdx=transpose(newIdx);
            newIdx=newIdx(:);
        end

        function[funStr,numParens]=buildNonlinearStr(~,~,...
            leftVarName,~,leftParens,~)
            funStr=leftVarName+".'";
            numParens=leftParens+1;
        end


        function out=evaluate(~,Left,~,~)
            out=transpose(Left);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorTranspose(visitor,op,Node);
        end
    end

    methods(Access=protected)

        function ok=checkIsValid(~,Left,~)
            leftSize=getSize(Left);
            if numel(leftSize)>2
                throwAsCaller(MException(message('shared_adlib:operators:TransposeNDArray')));
            end
            ok=true;
        end
    end

end

