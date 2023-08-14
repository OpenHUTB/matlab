function outSurface=fillmissing(inpSurface,dim)


















%#codegen

    coder.allowpcode('plain');


    if dim==2
        transposedSurface=gpucoder.transpose(inpSurface);
    else
        transposedSurface=inpSurface;
    end



    nRows=size(transposedSurface,1);
    nCols=size(transposedSurface,2);



    missingSurf=coder.nullcopy(zeros(nRows,nCols));
    nonMissingSurf=coder.nullcopy(zeros(nRows,nCols));
    countNonMissing=zeros(1,nCols,'uint32');
    countMissing=zeros(1,nCols,'uint32');
    coder.gpu.kernel;
    for cIter=1:nCols
        coder.gpu.kernel;
        for rIter=1:nRows
            isFiniteFlag=isfinite(transposedSurface(rIter,cIter));
            missingSurf(rIter,cIter)=~isFiniteFlag;
            nonMissingSurf(rIter,cIter)=isFiniteFlag;
            countNonMissing(cIter)=gpucoder.atomicAdd(countNonMissing(cIter),...
            uint32(isFiniteFlag));
            countMissing(cIter)=gpucoder.atomicAdd(countMissing(cIter),...
            uint32(~isFiniteFlag));
        end
    end



    coder.gpu.kernel;
    for iter=1:nCols
        transposedSurface(:,iter)=fillSurface(transposedSurface(:,iter),missingSurf(:,iter),...
        nonMissingSurf(:,iter),countMissing(iter),countNonMissing(iter),...
        size(transposedSurface,dim));
    end


    if dim==2
        outSurface=gpucoder.transpose(transposedSurface);
    else
        outSurface=transposedSurface;
    end



end

function outSurfCol=fillSurface(inpSurfCol,missingSurfCol,nonMissingSurfCol,countMissingCol,...
    countNonMissingCol,lengthTranspSurface)
































    outSurfCol=inpSurfCol;



    spValues=(1:lengthTranspSurface)';
    if countNonMissingCol>1&&countMissingCol>0
        outSurfCol(missingSurfCol)=interp1(spValues(nonMissingSurfCol),outSurfCol(nonMissingSurfCol),...
        spValues(missingSurfCol),'nearest','extrap');
    end



    linearIndices=1:numel(nonMissingSurfCol);
    nonMissingIndices=vision.internal.codegen.gpu.pcfitplane.findGpuImpl(linearIndices',...
    nonMissingSurfCol);
    indexBeg=nonMissingIndices(1);
    indexEnd=nonMissingIndices(end);




    outSurfCol(1:indexBeg-1)=inpSurfCol(indexBeg);
    outSurfCol(indexEnd+1:end)=inpSurfCol(indexEnd);

end
