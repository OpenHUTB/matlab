function[count,reshapeData]=convertSizeTo1xN(count)




    reshapeData=numel(count)>1;
    if reshapeData,
        count=prod(count);
    end


