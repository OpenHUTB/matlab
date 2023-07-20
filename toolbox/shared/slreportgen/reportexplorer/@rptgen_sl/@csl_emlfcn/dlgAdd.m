function dlgAdd(this)







    newProp=this.ArgSummTableOmittedProps{this.ArgSummTableAddPropIdx};



    props=this.ArgSummTableProps(:)';
    props={props{1:this.ArgSummTablePropIdx-1},...
    newProp,...
    props{this.ArgSummTablePropIdx:end}};




    cWid=this.ArgSummTableColWidths;
    cWid=[cWid(1:this.ArgSummTablePropIdx-1),...
    this.getDefaultArgPropColWidth(newProp),...
    cWid(this.ArgSummTablePropIdx:end)];




    cHead=this.ArgSummTableColHeaders;
    cHead={cHead{1:this.ArgSummTablePropIdx-1},...
    this.getDefaultArgPropColHeader(newProp),...
    cHead{this.ArgSummTablePropIdx:end}};




    omittedProps=this.ArgSummTableOmittedProps;
    this.ArgSummTableOmittedProps=...
    omittedProps(not(cellfun(@(a)strcmp(a,newProp),omittedProps)));

    this.ArgSummTableColHeaders=cHead;
    this.ArgSummTableColWidths=cWid;
    this.ArgSummTableProps=props;

