classdef Diff<optim.internal.problemdef.Operator






    properties

InputSize


Order


Dim
    end

    properties(Hidden,Constant)
        OperatorStr="diff";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        DiffVersion=1;
    end

    methods(Access=public)

        function op=Diff(inSz,order,dim)
            op.InputSize=inSz;
            [~,op.Order,op.Dim]=op.checkIsValid(order,dim);
        end


        function outSz=getOutputSize(op,~,~,~)

            outSz=op.InputSize;

            dim=op.Dim;

            N=op.Order;
            if isempty(dim)


                if N>sum(outSz)-numel(outSz)
                    outSz=[0,0];
                    return;
                end



                dim=find(outSz~=1,1,'first');

                m=outSz(dim);
                while N>0&&m>0


                    ntodo=min(m-1,N);

                    outSz(dim)=m-ntodo;
                    N=N-ntodo;

                    dim=find(outSz~=1,1,'first');
                    if isempty(dim)


                        return;
                    end
                    m=outSz(dim);
                end
            else

                outSz=op.InputSize;

                ndims=numel(outSz);

                outSz=[outSz,ones(1,dim-ndims)];

                m=outSz(dim);


                outSz(dim)=max(0,m-N);
            end
        end


        function numParens=getOutputParens(~)
            numParens=1;
        end

        function[funStr,numParens]=buildNonlinearStr(op,~,...
            leftVarName,~,leftParens,~)

            if isempty(op.Dim)
                funStr=op.OperatorStr+"("+leftVarName+", "+op.Order+")";
            else
                funStr=op.OperatorStr+"("+leftVarName+", "+op.Order+", "+op.Dim+")";
            end
            numParens=leftParens+1;
        end


        function val=evaluate(op,Left,~,~)
            if isempty(op.Dim)
                val=diff(Left,op.Order);
            else
                val=diff(Left,op.Order,op.Dim);
            end
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorDiff(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function[ok,order,dim]=checkIsValid(~,order,dim)

            if isempty(order)
                order=1;
            elseif(~isnumeric(order)&&~islogical(order))||~isscalar(order)||~isreal(order)
                throwAsCaller(MException(message('MATLAB:diff:differenceOrderMustBePositiveInteger')));
            elseif any(isinf(order))||any(isnan(order))
                throwAsCaller(MException(message('MATLAB:nonaninf')));
            elseif order<=0||floor(order)~=order
                throwAsCaller(MException(message('MATLAB:diff:differenceOrderMustBePositiveInteger')));
            end

            if~isempty(dim)
                if(~isnumeric(dim)&&~islogical(dim))||~isscalar(dim)||~isreal(dim)||...
                    floor(dim)~=dim||dim<1||~isfinite(dim)
                    throwAsCaller(MException(message('MATLAB:getdimarg:dimensionMustBePositiveInteger')));
                end
            end

            ok=true;
        end

    end

end
