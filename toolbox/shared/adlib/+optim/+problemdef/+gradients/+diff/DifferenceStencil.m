function[diffStencil,opExprSz]=DifferenceStencil(opExprSz,diffOrder,diffDim)







    if diffOrder==1
        coeff=[-1,1];
    elseif diffOrder==2
        coeff=[1,-2,1];
    elseif diffOrder==3
        coeff=[-1,3,-3,1];
    else
        coeff=poly(ones(1,diffOrder)).*(-1).^diffOrder;
    end


    stride=prod(opExprSz(1:diffDim-1));



    nDiffDim=opExprSz(diffDim);
    diffStencil=sparse(ones(1,diffOrder+1),1:stride:stride*(diffOrder+1),coeff,1,stride*nDiffDim);


    newDiffDim=nDiffDim-diffOrder;
    opExprSz(diffDim)=newDiffDim;



    NMidDim=stride*newDiffDim;
    col=sparse(1,1,coeff(1),1,NMidDim);
    diffStencil=toeplitz(col,diffStencil);


    NendDim=prod(opExprSz(diffDim+1:end));
    if NendDim>1
        diffStencil=kron(speye(NendDim),diffStencil);
    end

end
