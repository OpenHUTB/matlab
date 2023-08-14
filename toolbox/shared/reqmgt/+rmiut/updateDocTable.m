function docTable=updateDocTable(docTable,subTable)
    for i=1:size(subTable,1)
        docTable=insertInTable(docTable,subTable{i,1},subTable{i,2});
    end
end

function docTable=insertInTable(docTable,doc,count)
    if isempty(docTable)
        docTable{1,1}=doc;
        docTable{1,2}=count;
    else
        matched=strcmp(docTable(:,1),doc);
        if any(matched)
            docTable{matched,2}=docTable{matched,2}+count;
        else
            docTable{end+1,1}=doc;
            docTable{end,2}=count;
        end
    end
end
