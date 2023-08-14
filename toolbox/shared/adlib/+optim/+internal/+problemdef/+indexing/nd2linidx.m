function linIdx=nd2linidx(nDims,idxIn,exprSize)











    if nDims==2

        idx1=idxIn{1}(:);
        idx2=idxIn{2}(:)';


        linIdx=(idx2-1)*exprSize(1)+idx1;
    else
        linIdx=idxIn{1};
        prodDim=1;
        for k=2:nDims
            prodDim=prodDim*exprSize(k-1);
            linIdx=linIdx(:)+prodDim*(idxIn{k}(:)'-1);
        end
    end