function colId=getColId(this,col)




    switch col
    case 'idxopt'
        colId=1;
    case 'idx'
        colId=2;
    case 'outsize'
        colId=3;
    otherwise
        colId=-1;
    end

end