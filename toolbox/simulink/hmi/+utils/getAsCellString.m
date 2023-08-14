

function cellStr=getAsCellString(numericArr)

    cellStr=cell(1,length(numericArr));
    for i=1:length(numericArr)
        cellStr{i}=num2str(numericArr(i),16);
    end
end