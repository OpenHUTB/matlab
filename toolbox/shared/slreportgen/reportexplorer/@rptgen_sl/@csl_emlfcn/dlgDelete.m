function dlgDelete(this)









    props=this.ArgSummTableProps;
    propCount=length(props);
    cWid=this.ArgSummTableColWidths;
    cHead=this.ArgSummTableColHeaders;

    deletedProp=props(this.ArgSummTablePropIdx);

    newIdx=[1:this.ArgSummTablePropIdx-1,...
    this.ArgSummTablePropIdx+1:propCount];

    this.ArgSummTableProps=props(newIdx);
    this.ArgSummTableColWidths=cWid(newIdx);
    this.ArgSummTableColHeaders=cHead(newIdx);

    if this.ArgSummTablePropIdx==propCount
        this.ArgSummTablePropIdx=this.ArgSummTablePropIdx-1;
    end

    props=this.ArgSummTableOmittedProps;
    props=[props;deletedProp];
    this.ArgSummTableOmittedProps=sort(props);





