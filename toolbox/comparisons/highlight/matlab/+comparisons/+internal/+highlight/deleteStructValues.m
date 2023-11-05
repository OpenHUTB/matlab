function deleteStructValues(structVal)

    for fieldName=string(fieldnames(structVal))'
        delete(structVal.(fieldName))
        structVal=rmfield(structVal,fieldName);
    end

end
