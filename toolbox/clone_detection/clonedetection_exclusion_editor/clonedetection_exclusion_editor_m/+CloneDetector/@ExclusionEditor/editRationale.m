function result=editRationale(this,rowData)



    columnIndexOfRational=3;
    indexToEdit=rowData.viewRange.rows.start+1;
    this.TableData{indexToEdit}(columnIndexOfRational)={rowData.newValue};

    result=this.TableData;
    this.updateDialogForAction(this.UpdateDialogAction.Dirty);
end