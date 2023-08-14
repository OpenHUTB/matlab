function percentage=calculatePercentage(partValue,totalValue,valueIfZero)




    if nargin<3
        valueIfZero=0;
    end

    if totalValue>0&&partValue>0
        percentage=100*partValue/totalValue;
    else
        percentage=valueIfZero;
    end
end
