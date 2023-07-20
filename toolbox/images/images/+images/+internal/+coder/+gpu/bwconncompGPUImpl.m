
function[regionIdx,regionLengths,numRegions]=bwconncompGPUImpl(inpImg,nhood)%#codegen







    coder.allowpcode('plain');
    coder.inline('always');


    coder.gpu.internal.kernelfunImpl(false);


    [imgRows,imgCols,~]=size(inpImg);



    threads2D=[32,8,1];
    blocks2D=divup([imgRows,imgCols,1],threads2D);


    loopsPerThread=16;
    threads1D=[256,1,1];
    numBlocks=divup(numel(inpImg),loopsPerThread*threads1D(1));
    blocks_y=divup(numBlocks,256*256-1);
    blocks1D=[divup(numBlocks,blocks_y),blocks_y,1];


    labelledImg=coder.nullcopy(cast(inpImg,'double'));


    coder.gpu.internal.kernelImpl(false,blocks1D,threads1D,-1,'LabellingKernel');
    for i=1:numel(inpImg)
        if inpImg(i)
            labelledImg(i)=i;
        else
            labelledImg(i)=0;
        end
    end


    reIterLabellingFlag=true;

    while(reIterLabellingFlag)
        reIterLabellingFlag=false;

        coder.gpu.internal.kernelImpl(false,blocks2D,threads2D,-1,'ScanningKernel');
        for colIter=1:imgCols
            coder.gpu.internal.kernelImpl(false,blocks2D,threads2D,-1,'ScanningKernel');
            for rowIter=1:imgRows


                label=labelledImg(rowIter,colIter);
                if label==0
                    continue;
                end


                minVal=searchNhoodForMinVal(labelledImg,rowIter,colIter,imgRows,imgCols,nhood);




                if minVal<label
                    current=labelledImg(label);
                    labelledImg(label)=min(current,minVal);
                    reIterLabellingFlag=true;
                end
            end
        end


        skipVal=blocks1D(1)*blocks1D(2)*threads1D(1);
        coder.gpu.internal.kernelImpl(false,blocks1D,threads1D,-1,'AnalysisKernel');
        for j=1:skipVal
            for i=1:skipVal:numel(labelledImg)
                combIter=i+j-1;
                if combIter>numel(labelledImg)
                    continue;
                end
                label=labelledImg(combIter);
                origLabel=label;

                if label
                    ref=labelledImg(label);
                    while(ref~=label)
                        label=ref;
                        ref=labelledImg(label);
                    end

                    if label~=origLabel
                        labelledImg(combIter)=label;
                    end
                end

            end
        end
    end


    [sortedList,regionIdx_withZeros]=gpucoder.sort(labelledImg(:));


    numRegions=uint32(0);
    for i=1:numel(labelledImg)
        if labelledImg(i)==i
            numRegions=gpucoder.atomicAdd(numRegions,uint32(1));
        end
    end
    numRegions=cast(numRegions,'double');


    startIndices=zeros(1,numRegions+1,'int32');
    counter=uint32(1);

    coder.gpu.internal.kernelImpl(false);
    for i=1:numel(labelledImg)-1
        if(sortedList(i)~=sortedList(i+1))
            [counter,oldVal]=gpucoder.atomicAdd(counter,uint32(1));
            startIndices(oldVal)=i+1;
        end
    end
    startIndices(end)=1;


    startIndices=gpucoder.sort(startIndices);

    regionIdx=regionIdx_withZeros(startIndices(2):end);
    regionLengths=[transpose(startIndices(3:end)-startIndices(2:end-1));numel(labelledImg)-startIndices(end)+1];
end


function minVal=searchNhoodForMinVal(labelledImg,rowIter,colIter,imgRows,imgCols,nhood)
    minVal=numel(labelledImg)+1;
    if rowIter-1>0
        minVal=nonZeroMin(labelledImg(rowIter-1,colIter),minVal);
    end
    if colIter-1>0
        minVal=nonZeroMin(labelledImg(rowIter,colIter-1),minVal);
    end

    minVal=nonZeroMin(labelledImg(rowIter,colIter),minVal);

    if colIter+1<=imgCols
        minVal=nonZeroMin(labelledImg(rowIter,colIter+1),minVal);
    end

    if rowIter+1<=imgRows
        minVal=nonZeroMin(labelledImg(rowIter+1,colIter),minVal);
    end

    if nhood==8&&rowIter-1>0&&colIter-1>0
        minVal=nonZeroMin(labelledImg(rowIter-1,colIter-1),minVal);
    end

    if nhood==8&&rowIter-1>0&&colIter+1<=imgCols
        minVal=nonZeroMin(labelledImg(rowIter-1,colIter+1),minVal);
    end
    if nhood==8&&rowIter+1<=imgRows&&colIter-1>0
        minVal=nonZeroMin(labelledImg(rowIter+1,colIter-1),minVal);
    end
    if nhood==8&&rowIter+1<=imgRows&&colIter+1<=imgCols
        minVal=nonZeroMin(labelledImg(rowIter+1,colIter+1),minVal);
    end
end


function out=nonZeroMin(a,b)
    coder.inline('always');
    if a==0
        out=b;
    elseif b==0
        out=a;
    else
        out=min(a,b);
    end
end


function blocks=divup(n,threads)
    coder.inline('always');
    blocks=floor((n+threads-1)./threads);
end
