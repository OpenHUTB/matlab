function dlgMoveDown(this)








    props=this.ArgSummTableProps;
    propCount=length(props);

    if this.ArgSummTablePropIdx<propCount;
        cWid=this.ArgSummTableColWidths;
        cHead=this.ArgSummTableColHeaders;

        newIdx=[1:this.ArgSummTablePropIdx-1,...
        this.ArgSummTablePropIdx+1,...
        this.ArgSummTablePropIdx,...
        this.ArgSummTablePropIdx+2:propCount];

        this.ArgSummTableProps=props(newIdx);
        this.ArgSummTableColWidths=cWid(newIdx);
        this.ArgSummTableColHeaders=cHead(newIdx);

        this.ArgSummTablePropIdx=this.ArgSummTablePropIdx+1;
    end



