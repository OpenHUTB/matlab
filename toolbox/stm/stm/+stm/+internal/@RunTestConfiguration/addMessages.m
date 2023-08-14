function addMessages(obj,messages,errorOrLog)




    assert(length(messages)==length(errorOrLog));
    for k=1:length(errorOrLog)
        obj.out.messages{end+1}=messages{k};
        obj.out.errorOrLog{end+1}=errorOrLog{k};
    end
end

