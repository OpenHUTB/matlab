classdef SumOperator<optim.internal.problemdef.Operator




    properties(Hidden=true)

        LeftSize=[0,0]

        Dimension=1
    end

    properties(Hidden,Constant)
        OperatorStr="sum"
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SumOperatorVersion=1;
    end

    methods

        function op=SumOperator(Left,dim)

            op.LeftSize=getSize(Left);
            if nargin<2


                idx=find(op.LeftSize~=1,1);
                if~isempty(idx)

                    op.Dimension=idx;
                else

                    op.Dimension=1;
                end
            else

                [~,dim]=checkIsValid(op,Left,dim);

                if matlab.internal.datatypes.isScalarText(dim)
                    op.Dimension=dim;
                else


                    op.Dimension=double(dim);
                end
            end
        end


        function outSize=getOutputSize(op,~,~,~)

            if matlab.internal.datatypes.isScalarText(op.Dimension)
                outSize=[1,1];
            else
                outSize=op.LeftSize;
                if op.Dimension<=numel(outSize)
                    outSize(op.Dimension)=1;
                end
            end

        end


        function numParens=getOutputParens(~)
            numParens=1;
        end

        function[funStr,numParens]=buildNonlinearStr(op,visitor,...
            leftVarName,~,leftParens,~)


            dim=op.Dimension;

            nonscalarDim=op.LeftSize~=1;

            if matlab.internal.datatypes.isScalarText(dim)
                funStr="sum("+leftVarName+", 'all')";
            elseif visitor.ForDisplay&&((sum(nonscalarDim)==1&&dim==find(nonscalarDim,1,'first'))...
                ||all(nonscalarDim==false))



                funStr="sum("+leftVarName+")";
            else
                funStr="sum("+leftVarName+", "+dim+")";
            end
            numParens=leftParens+1;
        end


        function out=evaluate(op,Left,~,~)
            out=sum(Left,op.Dimension);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorSum(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function[ok,dim]=checkIsValid(~,~,dim)

            if~matlab.internal.datatypes.isScalarText(dim)

                if(~isnumeric(dim)&&~islogical(dim))||~isscalar(dim)||~isreal(dim)||...
                    floor(dim)~=dim||dim<1||~isfinite(dim)
                    throwAsCaller(MException(message('shared_adlib:operators:DimensionMustBePositiveInteger')));
                end
            else


                dim=optim.internal.problemdef.operator.checkStringInputToProdAndSum(dim);
            end
            ok=true;
        end
    end

end
