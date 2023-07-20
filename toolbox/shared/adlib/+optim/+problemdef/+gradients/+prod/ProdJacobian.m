function gradJacTrans=ProdJacobian(opExpr,prodDim)








    inputSize=size(opExpr);
    nDim=numel(inputSize);
    pattern=1;
    diagDim=1;









































    for idx=1:nDim
        if any(prodDim==idx)

            pattern=kron(speye(diagDim),pattern);
            diagDim=1;

            pattern=repmat(pattern,inputSize(idx),1);
        else
            diagDim=diagDim*inputSize(idx);
        end
    end












    gradStencil=kron(speye(diagDim),pattern);


    gradJacTrans=iProdJacobian(opExpr,prodDim);
    gradJacTrans=gradStencil.*gradJacTrans(:);

end

function dX=iProdJacobian(X,prodDim)


    isReduceDim=false(1,ndims(X));
    isReduceDim(prodDim)=true;



    if issorted(isReduceDim,'descend')

        dim=1;
        rowsXmat=prod(size(X,find(isReduceDim)));
        perm=[];
    elseif issorted(isReduceDim,'ascend')

        dim=2;
        rowsXmat=prod(size(X,find(~isReduceDim)));
        perm=[];
    else

        dim=1;
        rowsXmat=prod(size(X,find(isReduceDim)));
        [~,perm]=sort(isReduceDim,'descend');
        X=permute(X,perm);
    end


    szX=size(X);
    X=reshape(X,rowsXmat,[]);


    upperProd=circshift(X,-1,dim);
    if dim==1
        upperProd(end,:)=1;
    else
        upperProd(:,end)=1;
    end
    upperProd=cumprod(upperProd,dim,'reverse');



    lowerProd=circshift(matlab.lang.internal.move(X),1,dim);
    if dim==1
        lowerProd(1,:)=1;
    else
        lowerProd(:,1)=1;
    end
    lowerProd=cumprod(lowerProd,dim);



    dX=matlab.lang.internal.move(lowerProd).*matlab.lang.internal.move(upperProd);

    dX=reshape(dX,szX);

    if~isempty(perm)

        dX=ipermute(dX,perm);
    end

end
