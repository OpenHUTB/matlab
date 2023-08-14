function toolstripRemoveCB(this)






    if isempty(this.SessionSource),return;end

    sel=this.BindingTable.Selection;
    this.BindingData(sel)=[];
    this.BindingTable.Data(sel,:)=[];
    this.BindingTable.Selection=[];
    this.bindingTableCellSelectionCB();
    this.refreshStyles();
end

