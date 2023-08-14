function isEqual=areControlVariablesEqual(xArr,yArr)



    xArrSorted=sortStructArr(xArr,"Name");
    yArrSorted=sortStructArr(yArr,"Name");
    isEqual=isequal(xArrSorted,yArrSorted);
end

function sortedStruct=sortStructArr(structArray,fieldName)

    [~,idx]=sort({structArray.(fieldName)});
    sortedStruct=structArray(idx);
end
