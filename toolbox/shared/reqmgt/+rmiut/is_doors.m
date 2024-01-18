function result=is_doors(doc)
    if isempty(regexp(doc,'^[\da-f]{8,8}($| )','once'))
        result=false;
    else
        result=true;
    end
