function importOptions=convertAttributesToHeaders(importOptions)




    if isfield(importOptions,'columns')&&length(importOptions.columns)==2
        importOptions.columns=ensureFullListOfColumns(importOptions);
    end

    if~isfield(importOptions,'headers')&&isfield(importOptions,'attributes')&&isfield(importOptions,'columns')






        [uniqueAttributeColumns,colIdx]=unique(importOptions.attributeColumn);
        uniqueAttributeNames=unique(importOptions.attributes);
        if length(uniqueAttributeColumns)<length(importOptions.attributeColumn)
            error(message('Slvnv:slreq_import:ValusMustBeUnique','attributeColumn'));
        elseif length(uniqueAttributeNames)<length(importOptions.attributes)
            error(message('Slvnv:slreq_import:ValusMustBeUnique','attributeColumn'));
        elseif length(importOptions.attributes)~=length(importOptions.attributeColumn)
            error(message('Slvnv:slreq_import:CustomHeadersLengthMismatch',...
            num2str(length(importOptions.attributes)),num2str(length(importOptions.attributeColumn))));
        end




        if any(uniqueAttributeColumns~=importOptions.attributeColumn)
            importOptions.attributeColumn=importOptions.attributeColumn(colIdx);
            importOptions.attributes=importOptions.attributes(colIdx);
        end


        importOptions.headers=repmat({''},size(importOptions.columns));
        [~,attrIdx]=intersect(importOptions.columns,importOptions.attributeColumn);
        importOptions.headers(attrIdx)=importOptions.attributes;
    end
end


function columns=ensureFullListOfColumns(options)
    if isMissing('idColumn')||isMissing('summaryColumn')||isMissing('keywordsColumn')...
        ||isMissing('descriptionColumn')||isMissing('rationaleColumn')||isMissing('attributeColumn')
        columns=options.columns(1):options.columns(end);
    else
        columns=options.columns;
    end

    function tf=isMissing(fieldName)
        tf=isfield(options,fieldName)&&~isempty(setdiff(options.(fieldName),options.columns));
    end
end


