


function setFieldsFromFilterJSONDelete(obj,filterJSON)

    obj.clearComments();
    for i=1:numel(filterJSON)
        if iscell(filterJSON)
            setFieldsFromFilterJSONHelper(obj,filterJSON{i,1});
        else
            setFieldsFromFilterJSONHelper(obj,filterJSON(i));
        end
    end
end
