function out=getFunctionArguments(obj,fcnInfo)
    import mlreportgen.dom.*
    n=length(fcnInfo.Prototype.Arguments);
    if n==0
        out=Text('None');
        return
    end
    t=Table(4);
    tr=TableRow();
    td=TableEntry('#');
    td.Style={Bold};
    tr.append(td);
    tr.append(TableEntry(DAStudio.message('RTW:codeInfo:reportNameHeading')));
    tr.append(TableEntry(DAStudio.message('RTW:codeInfo:reportDataTypeHeading')));
    tr.append(TableEntry(DAStudio.message('RTW:codeInfo:reportDescriptionHeading')));
    t.append(tr);
    for k=1:n
        tr=TableRow();
        arg=fcnInfo.Prototype.Arguments(k);
        td=TableEntry(num2str(k));
        td.Style={Bold};
        tr.append(td);

        tr.append(TableEntry(arg.Name));
        tr.append(TableEntry(getTypeIdentifier(arg.Type)));
        tr.append(TableEntry(obj.getGraphicalPath(fcnInfo.ActualArgs(k))));
        t.append(tr);
    end
    t.StyleName='TableStyleSimple';
    out=t;
end
