

function combinedRows=combineSelectedAndConnectedRows(selectionRows,connectedRows)


    combinedRows=selectionRows;
    if(numel(connectedRows)==0)
        return;
    end
    rowsToAdd=cell(1,numel(connectedRows));
    for i=1:numel(connectedRows)
        if isprop(connectedRows{i}.bindableMetaData,'id')==false

            rowsToAdd{i}=connectedRows{i};
            continue;
        end
        foundDuplicate=false;
        for j=1:numel(combinedRows)
            if(isprop(combinedRows{j}.bindableMetaData,'id')&&strcmp(connectedRows{i}.bindableMetaData.id,combinedRows{j}.bindableMetaData.id))


                combinedRows{j}.isConnected=connectedRows{i}.isConnected;
                combinedRows{j}.bindableMetaData=connectedRows{i}.bindableMetaData;
                foundDuplicate=true;
            end
        end
        if(~foundDuplicate)
            rowsToAdd{i}=connectedRows{i};
        end
    end
    rowsToAdd=rowsToAdd(~cellfun('isempty',rowsToAdd));
    combinedRows=[combinedRows,rowsToAdd];
end