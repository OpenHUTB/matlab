function gradJacTrans=CumprodJacobian(opExpr,prodDim,direction)











    inputSize=size(opExpr);
    gradStencil=...
    optim.problemdef.gradients.cumulative.CumulativeStencil(inputSize,prodDim,direction,1);





    gradStencil=gradStencil+gradStencil.';







    processOpExpr=opExpr(:).';
    mapZero=(processOpExpr==0);
    opExprHasZeroVals=any(mapZero);

    if opExprHasZeroVals





        [I,J,V]=find(gradStencil);
        V(mapZero(J(:)))=NaN;
        gradStencil=sparse(I,J,V);
    end



    gradJacTrans=processOpExpr.'.*gradStencil.';



    rows=size(gradStencil,1);
    gradJacTrans(1:rows+1:end)=1;








    [I,J,V]=find(gradJacTrans);







    if opExprHasZeroVals
        V(mapZero(I(:)))=0;
        V(I(:)==J(:))=1;
    end



    cols=size(gradJacTrans,2);
    rowIdx=[0;find(diff(J(:)));numel(J)];









    for idx=1:cols
        idxStart=rowIdx(idx)+1;
        idxEnd=rowIdx(idx+1);
        V(idxStart:idxEnd)=cumprod(V(idxStart:idxEnd),direction);
    end



    gradJacTrans=sparse(J,I,V);

    if strcmpi(direction,"forward")
        gradJacTrans=triu(gradJacTrans);
    else
        gradJacTrans=tril(gradJacTrans);
    end

end

