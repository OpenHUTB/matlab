function dlgStruct=getDialogSchema(this,~)





























    this.cacheDialogParams;





    numItems=0;

    tblInpIter=this.getInpKernelTblWidget;
    tblInpIter.RowSpan=[2,max(tblInpIter.RowSpan(2),3)];
    numItems=numItems+1;
    items{1,numItems}=tblInpIter;

    inputDescText.Name=DAStudio.message('Simulink:dialog:NeighborhoodInputGroupDesc');
    inputDescText.Type='text';
    inputDescText.WordWrap=true;
    inputDescText.RowSpan=[1,1];
    inputDescText.ColSpan=[1,3];
    inputDescText.Visible=true;
    numItems=numItems+1;
    items{1,numItems}=inputDescText;

    numRows=items{1}.RowSpan(2);

    dlgStruct=this.constructDlgStruct(items,numRows);

end
