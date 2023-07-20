function[Aout,bout]=visitOperatorTransposeWithIndex(~,ALeft,bLeft,NewIdxOrder)






    if nnz(ALeft)>0
        Aout=ALeft(:,NewIdxOrder);
    else
        Aout=[];
    end
    bout=bLeft(NewIdxOrder(:));

end

