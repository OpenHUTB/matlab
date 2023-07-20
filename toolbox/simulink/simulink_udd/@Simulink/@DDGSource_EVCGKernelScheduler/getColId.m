function colId=getColId(~,col)




    switch col
    case 'blkname'
        colId=1;

    case 'inpIter'
        colId=2;

    otherwise
        colId=-1;
    end

end
