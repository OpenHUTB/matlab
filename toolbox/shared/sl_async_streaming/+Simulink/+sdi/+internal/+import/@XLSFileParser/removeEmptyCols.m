function[tt,types]=removeEmptyCols(this,tt,types)



    numVar=width(tt);
    for colIdx=numVar:-1:1
        colTypes=types(:,colIdx);
        emptyRows=colTypes==this.TypeIDs.EMPTY|...
        colTypes==this.TypeIDs.BLANK;
        vals=tt(emptyRows==0,colIdx);
        if isempty(vals)
            tt(:,colIdx)=[];
            types(:,colIdx)=[];
        end
    end
end