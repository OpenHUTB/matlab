function out=setCell(h,type,name,tag,row,col)

    out.Type=type;
    if length(name)>15
        name(15:end)=[];
        name=[name,'...'];
    end
    out.Name=name;
    out.Tag=tag;
    out.RowSpan=[row,row];
    out.ColSpan=[col,col];

