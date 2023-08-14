function OnTableFocusChangeCB(this,dlg,trow,col)



    srow=trow+1;
    if(srow==this.CurrRow),return;end

    this.CurrRow=srow;


    opsEns=this.GetTableOperationsEnables;

    dlg.setEnabled(this.AddRowTag,opsEns.AddRow);
    dlg.setEnabled(this.DeleteRowTag,opsEns.DeleteRow);
    dlg.setEnabled(this.MoveRowUpTag,opsEns.MoveRowUp);
    dlg.setEnabled(this.MoveRowDownTag,opsEns.MoveRowDown);


end

