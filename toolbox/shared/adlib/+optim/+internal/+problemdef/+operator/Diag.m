classdef Diag<optim.internal.problemdef.Operator






    properties

InputSize



DiagK


OutputSize
    end

    properties(Hidden,Constant)
        OperatorStr="diag";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        DiagVersion=1;
    end

    methods

        function op=Diag(inputSz,k)
            checkIsValid(op,inputSz,k);
            op.InputSize=inputSz;
            op.DiagK=k;
            op.OutputSize=op.computeOutputSize(inputSz,k);
        end


        function val=evaluate(op,Left,~,~)
            val=diag(Left,op.DiagK);
        end


        function outSize=getOutputSize(op,~,~,~)

            outSize=op.OutputSize;
        end


        function numParens=getOutputParens(~)
            numParens=1;
        end

        function[funStr,numParens]=buildNonlinearStr(op,visitor,...
            leftVarName,~,leftParens,~)

            dimK=op.DiagK;
            if visitor.ForDisplay&&dimK==0
                funStr=op.OperatorStr+"("+leftVarName+")";
            else
                funStr=op.OperatorStr+"("+leftVarName+", "+dimK+")";
            end
            numParens=leftParens+1;
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorDiag(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function ok=checkIsValid(~,inputSz,k)

            if numel(inputSz)>2
                throwAsCaller(MException(message('MATLAB:diag:firstInputMustBe2D')));
            end


            if(~isnumeric(k)&&~islogical(k))||~isscalar(k)||~isreal(k)||...
                floor(k)~=k||isnan(k)
                throwAsCaller(MException(message('MATLAB:diag:kthDiagInputNotInteger')));
            end


            if isinf(k)
                if any(inputSz==1)
                    throwAsCaller(MException(message('MATLAB:diag:kthDiagInputNotFinite')));
                end
            end

            ok=true;
        end

    end

    methods(Static,Access=protected)

        function outSize=computeOutputSize(inputSz,k)

            nElem=prod(inputSz);
            if any(inputSz==1)

                outSize=nElem+abs(k);
                outSize=[outSize,outSize];
            elseif all(inputSz==0)
                outSize=[0,0];
            else

                if k>0
                    outSize=min(inputSz(1),inputSz(2)-k);
                else
                    outSize=min(inputSz(2),inputSz(1)+k);
                end
                outSize=[max(outSize,0),1];
            end
        end
    end
end
