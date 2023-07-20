function newLinIdx=computeShiftedIdx(inSize,outSize,grownDims,firstProd,lastProd,shiftSize)





































    dim=grownDims(1);

    if nargin<4
        firstProd=prod(inSize(1:dim-1));
        lastProd=prod(inSize(dim+1:end));
        shiftSize=[ones(1,dim),inSize(dim+1:end)];
    end



    totalShift=computeIdxShift(inSize,outSize,dim,firstProd,lastProd,shiftSize);



    tempSize=inSize;
    tempSize(dim)=outSize(dim);
    for dim=grownDims(2:end)

        firstProd=prod(tempSize(1:dim-1));
        lastProd=prod(tempSize(dim+1:end));
        shiftSize=[ones(1,dim),tempSize(dim+1:end)];
        idxShift=computeIdxShift(inSize,outSize,dim,firstProd,lastProd,shiftSize);

        totalShift=totalShift+idxShift;


        tempSize(dim)=outSize(dim);
    end


    newLinIdx=reshape(1:prod(inSize),inSize)+totalShift;

    newLinIdx=newLinIdx(:)';
end

function idxShift=computeIdxShift(inSize,outSize,dim,firstProd,lastProd,shiftSize)


    idxShift=(outSize(dim)-inSize(dim))*firstProd;
    idxShift=0:idxShift:idxShift*(lastProd-1);

    idxShift=reshape(idxShift,shiftSize);
end