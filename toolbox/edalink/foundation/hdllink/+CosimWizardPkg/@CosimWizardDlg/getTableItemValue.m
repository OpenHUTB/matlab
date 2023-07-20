function val=getTableItemValue(this,dlg,tag,row,col)

    if~isempty(dlg)
        val=getTableItemValue(dlg,tag,row,col);
    else
        val=feval(['l_get',tag,'Value'],this,row,col);
    end

end

function val=l_getedaFileListValue(this,row,col)




    colItem=this.FileTable{row+1,col+1};
    switch col
    case 0,val=colItem;
    case 1,val=colItem.Entries{colItem.Value+1};
    otherwise,error(['(internal) bad col index: ',col]);
    end
end

function val=l_getedaInPortListValue(this,row,col)
    rowItem=this.UserData.InPortList{row+1};
    cidx2cname=containers.Map((0:5),properties(rowItem));
    intVal=rowItem.(cidx2cname(col));
    val=hdlv.vc.toString('InputPortType',intVal);
end

function val=l_getedaOutPortListValue(this,row,col)
    rowItem=this.UserData.OutPortList{row+1};
    cidx2cname=containers.Map((0:5),properties(rowItem));
    intVal=rowItem.(cidx2cname(col));
    val=hdlv.vc.toString('OutputPortType',intVal);
end

function val=l_getedaClocksValue(this,row,col)


    rowItem=this.UserData.ClkList{row+1};
    switch col
    case 0,colName='Name';
    case 1,colName='Period';
    case 2,colName='Edge';
    otherwise,error(['(internal) bad col index for ad-hoc ClkTable: ',col]);
    end
    val=rowItem.(colName);
end

function val=l_getedaResetsValue(this,row,col)
    rowItem=this.UserData.RstList{row+1};
    switch col
    case 0,colName='Name';
    case 1,colName='Initial';
    case 2,colName='Duration';
    otherwise,error(['(internal) bad col index for ad-hoc RstTable: ',col]);
    end
    val=rowItem.(colName);
end