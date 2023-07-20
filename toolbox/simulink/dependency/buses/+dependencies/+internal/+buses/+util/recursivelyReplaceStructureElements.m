function data=recursivelyReplaceStructureElements(data,fields,newElementName)





    data=i_replace(data,fields,newElementName);
end

function data=i_replace(data,fields,newElementName)
    outerField=fields(1);
    if~isfield(data,outerField)
        return;
    end
    if length(fields)>1
        innerFields=fields(2:end);
        data.(outerField)=arrayfun(@(f)i_replace(f,innerFields,...
        newElementName),data.(outerField));
    else
        data=i_replaceField(data,outerField,newElementName);
    end
end

function data=i_replaceField(data,oldFieldName,newFieldName)
    fieldsInOrder=string(fieldnames(data));
    fieldsInOrder(strcmp(fieldsInOrder,oldFieldName))=newFieldName;
    data.(newFieldName)=data.(oldFieldName);
    data=rmfield(data,oldFieldName);
    data=orderfields(data,fieldsInOrder);
end
