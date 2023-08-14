function result=cmpTimeFlag(file1,file2)










    if isempty(file1)
        result=2;
        return
    end

    if isempty(file2)
        result=-2;
        return
    end

    record1=dir(eval('file1'));
    [row,col]=size(record1);
    if(row==0)|(col==0)
        result=2;
        return
    end
    record2=dir(eval('file2'));
    [row,col]=size(record2);
    if(row==0)|(col==0)
        result=-2;
        return
    end

    date1=record1.datenum;
    date2=record2.datenum;

    if date1<date2
        result=1;
        return
    elseif date1>date2
        result=-1;
        return
    end

    result=0;
