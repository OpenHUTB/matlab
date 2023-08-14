classdef Prod<optim.internal.problemdef.Operator




    properties(Hidden=true)

        LeftSize=[0,0]


Dimension
    end

    properties(Hidden,Constant)
        OperatorStr="prod";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ProdVersion=1;
    end

    methods

        function op=Prod(Left,dim)




            op.LeftSize=getSize(Left);

            [~,dim]=checkIsValid(op,Left,dim);


            if matlab.internal.datatypes.isScalarText(dim)
                op.Dimension=dim;
            else
                op.Dimension=double(dim);
            end

        end


        function outSize=getOutputSize(op,~,~,~)

            outSize=op.LeftSize;

            dim=optim.internal.problemdef.operator.Prod.getReduceDim(op.Dimension,op.LeftSize);
            if strcmp(dim,'all')||isequal(op.LeftSize,[0,0])
                outSize=[1,1];
            else
                idxValidReduceDim=dim<=numel(outSize);
                outSize(dim(idxValidReduceDim))=1;
            end

        end


        function outType=getOutputType(op,LeftType,~,~)


            if LeftType==optim.internal.problemdef.ImplType.Numeric||...
                prod(op.LeftSize)==0
                outType=optim.internal.problemdef.ImplType.Numeric;
            else
                outType=optim.internal.problemdef.ImplType.Nonlinear;
            end
        end


        function numParens=getOutputParens(op)
            dimi=op.Dimension;
            if isempty(dimi)
                dimParens=0;
            elseif strcmp(dimi,'all')
                dimParens=0;
            else
                contiguous=false;
                [~,dimParens]=optim.internal.problemdef.compile.getVectorString(dimi,contiguous);
            end
            numParens=dimParens+1;
        end

        function[funStr,numParens]=buildNonlinearStr(op,~,...
            leftVarName,~,leftParens,~)

            dimi=op.Dimension;
            dimParens=0;
            if isempty(dimi)
                funStr="prod("+leftVarName+")";
            elseif strcmp(dimi,'all')
                funStr="prod("+leftVarName+", 'all')";
            else
                contiguous=false;
                [dimStr,dimParens]=optim.internal.problemdef.compile.getVectorString(dimi,contiguous);
                funStr="prod("+leftVarName+", "+dimStr+")";
            end
            numParens=leftParens+dimParens+1;
        end


        function out=evaluate(op,Left,~,~)
            if isempty(op.Dimension)&&isequal(op.LeftSize,[0,0])

                out=1;
            else
                dim=optim.internal.problemdef.operator.Prod.getReduceDim(op.Dimension,op.LeftSize);
                out=prod(Left,dim);
            end
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorProd(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function[ok,dim]=checkIsValid(~,~,dim)








            if isempty(dim)
                ok=true;
                return
            end

            if~matlab.internal.datatypes.isScalarText(dim)


                if(~isnumeric(dim)&&~islogical(dim))||~isvector(dim)||~isreal(dim)||...
                    any(floor(dim)~=dim)||any(dim<1)||any(~isfinite(dim))
                    throwAsCaller(MException(message('shared_adlib:operators:DimensionMustBePositiveInteger')));
                elseif numel(unique(dim))~=numel(dim)
                    throwAsCaller(MException(message('shared_adlib:operators:VecDimsMustBeUniquePositiveIntegers')));
                end
            else



                dim=optim.internal.problemdef.operator.checkStringInputToProdAndSum(dim);
            end
            ok=true;
        end


    end

    methods(Static)


        function dim=getReduceDim(dimIn,LeftSize)

            if isempty(dimIn)
                dim=find(LeftSize~=1,1,'first');
                if isempty(dim)

                    dim=1;
                end
            else
                dim=dimIn;
            end
        end

    end

end

