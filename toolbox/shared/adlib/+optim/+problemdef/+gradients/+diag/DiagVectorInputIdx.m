function idx=DiagVectorInputIdx(opExpr,diagK)










%#codegen
%#internal


    N=numel(opExpr);


    dim=N+abs(diagK);



    if diagK>0
        firstIdx=dim*diagK+1;
    else
        firstIdx=-diagK+1;
    end







    idx=firstIdx+(0:dim+1:(dim+1)*(N-1));
