function requestData(obj,ev)


    colList=ev.ColumnInfoRequests;
    colInfo=obj.getColumnInfo(colList);
    ev.addColumnInfo(colInfo);


    rowList=ev.RowInfoRequests;
    rowInfo=obj.getRowInfo(rowList);
    ev.addRowInfo(rowInfo);


    ranges=ev.RangeRequests;
    for i=1:length(ranges)
        range=ranges(i);
        rangeData=obj.getRangeData(range);
        ev.addRangeData(rangeData);
    end

    ev.send();