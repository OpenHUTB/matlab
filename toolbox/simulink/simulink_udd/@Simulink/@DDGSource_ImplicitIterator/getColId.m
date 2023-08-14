function colId=getColId(~,col)




    switch col
    case 'blkname'
        colId=1;

    case 'inpiter'
        colId=2;

    case 'inpiterdim'
        colId=3;

    case 'inpiterstepsize'
        colId=4;

    case 'inpiterstepoffset'
        colId=5;

    case 'outconcatdim'
        colId=2;

    otherwise
        colId=-1;
    end

end
