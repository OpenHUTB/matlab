function outImg=regionfillLaplaceGPUImpl(inpImg,mask,maskPerimeter)





















%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    [nRows,nCols]=size(inpImg);
    imageSize=nRows*nCols;


    outImg=inpImg;


    maskIdx=coder.nullcopy(zeros(1,imageSize));
    gridIdx=coder.nullcopy(zeros(1,imageSize));
    grid=zeros(nRows+2,nCols+2);



    maskCumSum=cumsum(mask(:));



    nonZeroMaskSize=maskCumSum(imageSize);


    if nonZeroMaskSize==imageSize
        coder.internal.warning('images:regionfill:maskIsAllWhite');
    end



    if nonZeroMaskSize==0
        return;
    end




    coder.gpu.kernel;
    for cIter=1:nCols
        coder.gpu.kernel;
        for rIter=1:nRows
            if mask(rIter,cIter)
                index=(cIter-1)*nRows+rIter;
                maskIdx(maskCumSum(index))=index;
                gridIdx(maskCumSum(index))=cIter*(nRows+2)+rIter+1;
            end

        end
    end



    rightSideTemp=formRightSide(inpImg,maskPerimeter);


    numNeighbors=computeNumberOfNeighbors(nRows,nCols);


    rightSide=coder.nullcopy(zeros(nonZeroMaskSize,1));



    coder.gpu.kernel;
    for iter=1:nonZeroMaskSize
        grid(gridIdx(iter))=iter;
        rightSide(iter)=rightSideTemp(maskIdx(iter));
    end



    m=nRows+2;
    direction=[-1,m,1,-m];
    nonZeroNeighbors=zeros(nonZeroMaskSize,4,'uint32');


    coder.gpu.nokernel;
    for counter=1:4
        coder.gpu.kernel;
        for iter=1:nonZeroMaskSize
            neighborVal=grid(gridIdx(iter)+direction(counter))~=0;
            nonZeroNeighbors(iter,counter)=neighborVal;
        end

    end


    nonZeroNeighborsCumSum=cumsum(nonZeroNeighbors(:));



    nonZeroNeighborsSize=nonZeroNeighborsCumSum(4*nonZeroMaskSize);


    totalSparseInputSize=nonZeroMaskSize+nonZeroNeighborsSize;
    I=coder.nullcopy(zeros(totalSparseInputSize,1,'int32'));
    J=coder.nullcopy(zeros(totalSparseInputSize,1,'int32'));
    S=coder.nullcopy(zeros(totalSparseInputSize,1));




    coder.gpu.kernel;
    for iter=1:nonZeroMaskSize
        I(iter)=int32(iter);
        J(iter)=int32(iter);
        S(iter)=numNeighbors(maskIdx(iter));
    end



    coder.gpu.kernel;
    for counter=1:4
        coder.gpu.kernel;
        for iter=1:nonZeroMaskSize
            neighborVal=int32(grid(gridIdx(iter)+direction(counter)));
            if neighborVal
                index=nonZeroMaskSize+nonZeroNeighborsCumSum((counter-1)*nonZeroMaskSize+iter);
                I(index)=int32(grid(gridIdx(iter)));
                J(index)=neighborVal;
                S(index)=-1;
            end
        end
    end



    [I,indexes]=gpucoder.sort(I);
    SortedJ=coder.nullcopy(zeros(totalSparseInputSize,1,'int32'));
    SortedS=coder.nullcopy(zeros(totalSparseInputSize,1));

    coder.gpu.kernel;
    for iter=1:totalSparseInputSize
        SortedJ(iter)=J(indexes(iter));
        SortedS(iter)=S(indexes(iter));
    end



    sol=images.internal.coder.gpu.solveLinearEquationGPUImpl(I,SortedJ,SortedS,rightSide);


    coder.gpu.kernel;
    for iter=1:nonZeroMaskSize
        outImg(maskIdx(iter))=sol(iter);
    end

end



















function rightSide=formRightSide(I,maskPerimeter)

    [nRow,nCol]=size(I);


    perimeterValues=zeros(nRow,nCol);
    perimeterValues(maskPerimeter)=I(maskPerimeter);


    rightSide=zeros(nRow,nCol);

    rightSide(2:nRow-1,2:nCol-1)=perimeterValues(1:nRow-2,2:nCol-1)...
    +perimeterValues(3:nRow,2:nCol-1)...
    +perimeterValues(2:nRow-1,1:nCol-2)...
    +perimeterValues(2:nRow-1,3:nCol);

    rightSide(2:nRow-1,1)=perimeterValues(1:nRow-2,1)...
    +perimeterValues(3:nRow,1)...
    +perimeterValues(2:nRow-1,2);

    rightSide(2:nRow-1,nCol)=perimeterValues(1:nRow-2,nCol)...
    +perimeterValues(3:nRow,nCol)...
    +perimeterValues(2:nRow-1,nCol-1);

    rightSide(1,2:nCol-1)=perimeterValues(2,2:nCol-1)...
    +perimeterValues(1,1:nCol-2)...
    +perimeterValues(1,3:nCol);

    rightSide(nRow,2:nCol-1)=perimeterValues(nRow-1,2:nCol-1)...
    +perimeterValues(nRow,1:nCol-2)...
    +perimeterValues(nRow,3:nCol);

    rightSide(1,1)=perimeterValues(1,2)+perimeterValues(2,1);
    rightSide(1,nCol)=perimeterValues(1,nCol-1)+perimeterValues(2,nCol);
    rightSide(nRow,1)=perimeterValues(nRow-1,1)+perimeterValues(nRow,2);
    rightSide(nRow,nCol)=perimeterValues(nRow-1,nCol)+perimeterValues(nRow,nCol-1);
end






function numNeighbors=computeNumberOfNeighbors(nRow,nCol)

    numNeighbors=zeros(nRow,nCol);

    numNeighbors(2:nRow-1,2:nCol-1)=4;

    numNeighbors(2:nRow-1,[1,nCol])=3;
    numNeighbors([1,nRow],2:nCol-1)=3;

    numNeighbors([1,1,nRow,nRow],[1,nCol,1,nCol])=2;
end
