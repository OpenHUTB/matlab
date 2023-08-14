function dlgStruct=getDialogSchema(this,~)





























    this.cacheDialogParams;





    numItems=0;
    paramFeatureOn=(slfeature('ForEachSubsystemParameterization')==1);

    tblInpIter=this.getInpIterTblWidget;
    tblInpIter.RowSpan=[2,max(tblInpIter.RowSpan(2),3)];
    numItems=numItems+1;
    items{1,numItems}=tblInpIter;

    tblOutConcat=this.getOutConcatTblWidget;
    tblOutConcat.RowSpan=[2,max(tblOutConcat.RowSpan(2),3)];
    numItems=numItems+1;
    items{1,numItems}=tblOutConcat;

    inputDescText.Name=DAStudio.message('Simulink:dialog:ForEachInputGroupDesc');
    inputDescText.Type='text';
    inputDescText.WordWrap=true;
    inputDescText.RowSpan=[1,1];
    inputDescText.ColSpan=[1,3];
    inputDescText.Visible=true;
    numItems=numItems+1;
    items{1,numItems}=inputDescText;

    outputDescText.Name=DAStudio.message('Simulink:dialog:ForEachOutputGroupDesc');
    outputDescText.Type='text';
    outputDescText.WordWrap=true;
    outputDescText.RowSpan=[1,1];
    outputDescText.ColSpan=[1,3];
    numItems=numItems+1;
    items{1,numItems}=outputDescText;

    if paramFeatureOn
        maskParamDescText.Name=DAStudio.message('Simulink:dialog:ForEachMaskPrmGroupDesc');
        maskParamDescText.Type='text';
        maskParamDescText.WordWrap=true;
        maskParamDescText.RowSpan=[1,1];
        maskParamDescText.ColSpan=[1,3];
        maskParamDescText.Visible=true;
        numItems=numItems+1;

        items{1,numItems}=maskParamDescText;
        tblMaskPrmIter=this.getMaskPrmIterTblWidget;
        tblMaskPrmIter.RowSpan=[2,max(tblMaskPrmIter.RowSpan(2),3)];
        numItems=numItems+1;
        items{1,numItems}=tblMaskPrmIter;
    end





























    if~paramFeatureOn
        numRows=[items{1}.RowSpan(2),items{2}.RowSpan(2)];
    else
        numRows=[items{1}.RowSpan(2),items{2}.RowSpan(2),items{6}.RowSpan(2)];
    end

    dlgStruct=this.constructDlgStruct(items,numRows);

end
