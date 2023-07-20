function id_string=getDocId(doc,docs_array,fallback_string)







    index=find(strcmp(doc,docs_array),1);
    if isempty(index)
        id_string=fallback_string;
    else
        id_string=['DOC',num2str(index)];
    end

