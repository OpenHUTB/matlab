function idx=Diag2DMatrixInputIdx(opExpr,diagK,Nout)











%#codegen
%#internal


    dims=size(opExpr);




    if diagK>0
        firstIdx=dims(1)*diagK+1;
    else
        firstIdx=-diagK+1;
    end



    idx=firstIdx+(0:dims(1)+1:(dims(1)+1)*(Nout-1));
