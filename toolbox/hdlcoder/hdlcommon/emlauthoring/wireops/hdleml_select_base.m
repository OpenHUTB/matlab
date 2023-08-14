%#codegen
function y=hdleml_select_base(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimOrder,dimIdx,outLen)
    coder.allowpcode('plain')
    dimNum=dimOrder(dimIdx);
    dimLength=size(datain,dimNum);


    dimInfo=[dimNum,dimLength,dimIdx,dimOrder];
    if outLen(dimNum)==0||outLen(dimNum)==1


        y=vectorHandling(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen);
    else
        y=startingIdxHandling(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen);
    end
end

function y=vectorHandling(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen)
    dimNum=dimInfo(1);

    vecLen=numel(indices.(structIdx(dimNum)));



    for idx=coder.unroll(1:vecLen)
        y=vectorHandlingLogic(y,datain,indices,[selectValIter,idx],dimIter,zeroBasedIndex,dimInfo,outLen);
    end
end

function y=vectorHandlingLogic(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen)
    dimNum=dimInfo(1);
    dimLength=dimInfo(2);
    dimIdx=dimInfo(3);
    dimOrder=dimInfo(4:end);
    currPortIdx=selectValIter(dimIdx);
    indexPort=indices.(structIdx(dimNum));
    currIndex=indexPort(currPortIdx);
    isIdxFinalDim=dimIdx==numel(size(y));

    for ii=coder.unroll(1:dimInfo(2)-1)
        if currIndex==cast(ii-zeroBasedIndex,'like',currIndex)
            if isIdxFinalDim
                y=selectFromInput(y,datain,[dimIter,ii],selectValIter,dimOrder);
            else

                y=hdleml_select_base(y,datain,indices,selectValIter,[dimIter,ii],zeroBasedIndex,dimOrder,dimIdx+1,outLen);
            end
            return
        end
    end
    if isIdxFinalDim

        y=selectFromInput(y,datain,[dimIter,dimLength],selectValIter,dimOrder);
    else

        y=hdleml_select_base(y,datain,indices,selectValIter,[dimIter,dimLength],zeroBasedIndex,dimOrder,dimIdx+1,outLen);
    end
end

function y=startingIdxHandling(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen)

    dimNum=dimInfo(1);
    dimLength=dimInfo(2);
    maxReachableIndex=dimLength-outLen(dimNum)+1;
    indexVal=indices.(structIdx(dimNum));
    for ii=coder.unroll(1:maxReachableIndex-1)
        if indexVal==cast(ii-zeroBasedIndex,'like',indexVal)

            y=startingIdxHandlingLogic(y,datain,indices,selectValIter,[dimIter,ii],zeroBasedIndex,dimInfo,outLen);
            return
        end
    end

    y=startingIdxHandlingLogic(y,datain,indices,selectValIter,[dimIter,maxReachableIndex],zeroBasedIndex,dimInfo,outLen);
end

function y=startingIdxHandlingLogic(y,datain,indices,selectValIter,dimIter,zeroBasedIndex,dimInfo,outLen)
    dimNum=dimInfo(1);
    dimIdx=dimInfo(3);
    dimOrder=dimInfo(4:end);
    currStaticIdx=dimIter(dimIdx);
    for ii=coder.unroll(currStaticIdx:currStaticIdx+outLen(dimNum)-1)
        dimIter(dimIdx)=ii;
        selectIdx=ii-currStaticIdx+1;
        newSelectValIter=[selectValIter,selectIdx];
        if dimIdx==numel(size(y))
            y=selectFromInput(y,datain,dimIter,newSelectValIter,dimOrder);
        else
            y=hdleml_select_base(y,datain,indices,newSelectValIter,dimIter,zeroBasedIndex,dimOrder,dimIdx+1,outLen);
        end
    end
end

function y=selectFromInput(y,datain,dimIter,selectValIter,dimOrder)
    if isscalar(datain)
        yIndex={1};
    elseif isvector(datain)
        yIndex={prod(selectValIter)};
    else
        yIndex=num2cell_local(selectValIter,dimOrder);
    end
    selectIndex=num2cell_local(dimIter,dimOrder);
    y(yIndex{:})=datain(selectIndex{:});
end

function cellarray=num2cell_local(array,order)
    cellarray=cell(1,numel(array));
    for ii=1:numel(array)
        cellarray{order(ii)}=array(ii);
    end
end