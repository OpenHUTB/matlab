function varargout=DiffJacobian(opExprSz,diffOrder,diffDim,nVar)










    outputType=nargout;
    JACOBIAN=1;
    HESSIAN=2;

    if isempty(diffDim)


        if diffOrder>sum(opExprSz)-numel(opExprSz)
            varargout{JACOBIAN}=sparse(0,prod(opExprSz));
            if outputType==HESSIAN
                varargout{HESSIAN}=sparse(0,nVar*prod(opExprSz));
            end
            return;
        end

        diffDim=find(opExprSz~=1,1,'first');

        m=opExprSz(diffDim);

        Jacobian=1;
        if(outputType==HESSIAN)
            varargout{HESSIAN}=1;
        end

        while diffOrder>0&&m>0


            ntodo=min(m-1,diffOrder);



            [JacobianK,opExprSz]=...
            optim.problemdef.gradients.diff.DifferenceStencil(opExprSz,ntodo,diffDim);


            Jacobian=JacobianK*Jacobian;



            if(outputType==HESSIAN)
                varargout{HESSIAN}=kron(JacobianK,speye(nVar))*varargout{HESSIAN};
            end


            diffDim=find(opExprSz~=1,1,'first');
            if isempty(diffDim)

                break;
            end

            m=opExprSz(diffDim);
            diffOrder=diffOrder-ntodo;
        end

        if(outputType==JACOBIAN||outputType==HESSIAN)
            varargout{JACOBIAN}=Jacobian;
        end

    else

        ndims=numel(opExprSz);


        opExprSz=[opExprSz,ones(1,diffDim-ndims)];


        m=opExprSz(diffDim);



        if(diffOrder>=m)

            varargout{JACOBIAN}=sparse(0,prod(opExprSz));
            if outputType==HESSIAN
                varargout{HESSIAN}=varargout{JACOBIAN};
            end
            return;
        end



        if(outputType==JACOBIAN||outputType==HESSIAN)
            varargout{JACOBIAN}=...
            optim.problemdef.gradients.diff.DifferenceStencil(opExprSz,diffOrder,diffDim);

            if(outputType==HESSIAN)
                varargout{HESSIAN}=varargout{JACOBIAN};
            end
        end

    end

end
