function sourceStructArray=appendToStructArray(sourceStructArray,structArrayToAppend)




    if isempty(fieldnames(sourceStructArray))
        sourceStructArray=structArrayToAppend;
    elseif~isempty(fieldnames(structArrayToAppend))
        sourceStructArray=[sourceStructArray,structArrayToAppend];
    end
end
