function appendIndex=getAppendIndexForStructArray(structArray)




    if isempty(fieldnames(structArray))
        appendIndex=1;
    else
        appendIndex=length(structArray)+1;
    end
end
