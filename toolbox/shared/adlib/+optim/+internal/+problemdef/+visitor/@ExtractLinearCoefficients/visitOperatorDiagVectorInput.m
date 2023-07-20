function[Aout,bout,idx]=visitOperatorDiagVectorInput(~,...
    ALeft,bLeft,inputSz,outputSz,diagK)








    if diagK>0
        firstIdx=outputSz(1)*diagK+1;
    else
        firstIdx=-diagK+1;
    end



    nElemIn=prod(inputSz);



    idx=firstIdx+(0:outputSz(1)+1:(outputSz(1)+1)*(nElemIn-1));
    nElemOut=prod(outputSz);

    if nnz(ALeft)>0









        nVar=size(ALeft,1);
        Iidx=repelem((1:nVar)',1,nElemIn);



        Jidx=repelem(idx,1,nVar);


        Aout=sparse(Iidx,Jidx,ALeft,nVar,nElemOut);
    else
        Aout=[];
    end
    bout=zeros(prod(outputSz),1);
    bout(idx)=bLeft;

end

