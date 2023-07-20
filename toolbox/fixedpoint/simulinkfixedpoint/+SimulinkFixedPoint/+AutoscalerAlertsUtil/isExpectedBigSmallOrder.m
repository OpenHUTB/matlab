function isAsExpected=isExpectedBigSmallOrder(biggerVal,smallerVal)






    isAsExpected=true;

    if(~isempty(biggerVal)&&...
        ~isempty(smallerVal)&&...
        biggerVal<smallerVal)

        isAsExpected=false;
    end

end
