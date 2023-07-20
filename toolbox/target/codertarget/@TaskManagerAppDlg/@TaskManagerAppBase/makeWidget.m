function widget=makeWidget(h,name,obj,type,entries,isObjMeth,method,row,col,enb,vis,mode)




    widget.Name=name;
    if~isempty(obj)
        widget.ObjectProperty=obj;
        widget.Tag=[widget.ObjectProperty,'Tag'];
    end
    widget.Type=type;
    widget.Entries=entries;
    widget.RowSpan=row;
    widget.ColSpan=col;
    if isObjMeth
        widget.ObjectMethod=method;
        widget.MethodArgs={'%dialog',obj,'%value'};
        widget.ArgDataTypes={'handle','mxArray','mxArray'};
    elseif~isempty(method)
        widget.MatlabMethod=method;
        widget.MatlabArgs={h.Root.getActiveConfigSet};
    end
    widget.Visible=vis;
    widget.Enabled=enb;
    widget.Tunable=false;
    widget.DialogRefresh=true;
    widget.Mode=mode;
    widget.Tunable=false;
end
