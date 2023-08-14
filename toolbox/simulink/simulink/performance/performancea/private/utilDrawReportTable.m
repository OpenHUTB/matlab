function resultTable=utilDrawReportTable(elements,tableName,RowHeading,ColHeading)





    [nRows,nCols]=size(elements);
    resultTable=ModelAdvisor.Table(nRows,nCols);

    resultTable.setHeading(tableName);
    resultTable.setHeadingAlign('center');

    if(~isempty(RowHeading))
        for i=1:nRows
            resultTable.setRowHeading(i,RowHeading{i})
        end
    end

    if(~isempty(ColHeading))
        for i=1:nCols
            resultTable.setColHeading(i,ColHeading{i});
        end
    end

    for irow=1:nRows
        for jcol=1:nCols
            resultTable.setEntry(irow,jcol,elements{irow,jcol});
        end
    end




    resultTable.setAttribute('width','80%');

end

