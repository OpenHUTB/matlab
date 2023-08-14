function dlgMoveUp(this)









    if this.ArgSummTablePropIdx>1
        props=this.ArgSummTableProps;
        propCount=length(props);
        cWid=this.ArgSummTableColWidths;
        cHead=this.ArgSummTableColHeaders;

        newIdx=[1:this.ArgSummTablePropIdx-2,...
        this.ArgSummTablePropIdx,...
        this.ArgSummTablePropIdx-1,...
        this.ArgSummTablePropIdx+1:propCount];

        this.ArgSummTableProps=props(newIdx);
        this.ArgSummTableColWidths=cWid(newIdx);
        this.ArgSummTableColHeaders=cHead(newIdx);

        this.ArgSummTablePropIdx=this.ArgSummTablePropIdx-1;
    end

