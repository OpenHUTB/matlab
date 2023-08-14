function dLabel=getDisplayLabel(this)




    childCount=0;
    thisChild=this.down;
    while~isempty(thisChild)
        childCount=childCount+1;
        thisChild=thisChild.right;
    end

    dLabel=sprintf(getString(message('rptgen:RptgenML_StylesheetRoot:stylesheetEditorLabelInt')),childCount);
