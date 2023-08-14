function out=getFunctionReturnValue(obj,fcnInfo)
    import mlreportgen.dom.*
    if isempty(fcnInfo.Prototype.Return)
        out=Text('None');
    else
        t=Table(2);
        tr=TableRow();
        tr.append(TableEntry(DAStudio.message('RTW:codeInfo:reportDataTypeHeading')));
        tr.append(TableEntry(DAStudio.message('RTW:codeInfo:reportDescriptionHeading')));
        tr.append(TableEntry(getTypeIdentifier(fcnInfo.Prototype.Return.Type)));
        tr.append(TableEntry(obj.getGraphicalPath(fcnInfo.ActualReturn)));
        t.StyleName='TableStyleSimple';
        out=t;
    end
end
