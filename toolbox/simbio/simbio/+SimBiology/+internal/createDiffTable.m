function[diffTable,componentTable]=createDiffTable(cellContent)

























    variableNames={'Class','Source','Target','Property','SourceValue','TargetValue'};
    nProperties=numel(variableNames);
    nDiffEntries=size(cellContent,1);

    tableContent=cell(1,nProperties);


    for propertyIdx=1:(nProperties-2)
        tableContent{propertyIdx}=string(cellContent(:,propertyIdx));
    end


    for propertyIdx=(nProperties-1):nProperties
        tableContent{propertyIdx}=cellContent(:,propertyIdx);
        for entryIdx=1:nDiffEntries
            entry=cellContent{entryIdx,propertyIdx};
            if ischar(entry)||iscellstr(entry)%#ok<ISCLSTR> 
                tableContent{propertyIdx}{entryIdx}=string(entry);
            end
        end
    end


    diffTable=table(tableContent{:},'VariableNames',variableNames);


    componentTable=table(cellContent(:,(nProperties+1)),cellContent(:,(nProperties+2)),...
    'VariableNames',{'Source','Target'});


    if nDiffEntries>0
        rowNames=arrayfun(@(row)string(row),1:nDiffEntries);
        diffTable.Properties.RowNames=rowNames;
        componentTable.Properties.RowNames=rowNames;
    end

end