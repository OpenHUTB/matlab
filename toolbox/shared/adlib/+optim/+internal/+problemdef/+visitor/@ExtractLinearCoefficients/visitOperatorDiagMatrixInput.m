function[Aout,bout,idx]=visitOperatorDiagMatrixInput(~,...
    ALeft,bLeft,inputSz,outputSz,diagK)








    if diagK>0
        firstIdx=inputSz(1)*diagK+1;
    else
        firstIdx=-diagK+1;
    end



    idx=firstIdx+(0:inputSz(1)+1:(inputSz(1)+1)*(outputSz(1)-1));

    if nnz(ALeft)>0


        Aout=ALeft(:,idx);
    else
        Aout=[];
    end
    bout=bLeft(idx);

