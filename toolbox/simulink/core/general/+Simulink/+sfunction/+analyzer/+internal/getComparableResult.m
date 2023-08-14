function comparableResult=getComparableResult(checkResult)




    [x,y]=size(checkResult);
    comparableResult=cell(x,y);
    for i=1:x
        for j=1:y
            if(j~=2)
                origTemp=checkResult{i,j};
                temp.summaryResult=origTemp.summaryResult;
                temp.summaryNum=origTemp.summaryNum;
                temp.target=origTemp.target;
                temp.category=origTemp.category;
                comparableResult{i,j}=temp;
            end
        end
    end
end

