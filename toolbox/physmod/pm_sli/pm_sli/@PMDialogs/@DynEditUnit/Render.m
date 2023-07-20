function[retVal,schema]=Render(hThis,schema)












    retVal=true;

    labelTxt.Name=[pm.sli.internal.resolveMessageString(hThis.Label),':'];
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,3];
    labelTxt.WordWrap=true;
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,...
    hThis.Items(1,1).ValueBlkParam);




    editElem=[];
    [retVal,editElem]=hThis.Items(1,1).Render(editElem);
    unitElem=[];
    [retVal,unitElem]=Render(hThis.Items(2,1),unitElem);

    confElem=[];
    if numel(hThis.Items)>2
        if hThis.BlockHandle.getDialogSource.ShowRuntime
            [retVal,confElem]=Render(hThis.Items(3,1),confElem);
        else

            hThis.Items(end)=[];
        end
    end

    editElem.RowSpan=[1,1];
    editElem.ColSpan=[1,1];
    unitElem.RowSpan=[1,1];
    unitElem.ColSpan=[2,2];

    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=3;
        editElem.RowSpan=[1,1];
        editElem.ColSpan=[1,2];
        unitElem.RowSpan=[1,1];
        unitElem.ColSpan=[3,3];
        items={editElem,unitElem,labelTxt};
        colStretch=[1,1,0];
    case 1
        nRows=1;
        nCols=6;
        editElem.RowSpan=[1,1];
        editElem.ColSpan=[2,5];
        unitElem.RowSpan=[1,1];
        unitElem.ColSpan=[6,6];
        labelTxt.ColSpan=[1,1];
        items={editElem,unitElem,labelTxt};
        colStretch=[0,1,1,1,1,0];
    case 2
        nRows=2;
        nCols=5;
        labelTxt.ColSpan=[1,5];
        editElem.RowSpan=[2,2];
        editElem.ColSpan=[1,3];
        unitElem.RowSpan=[2,2];
        unitElem.ColSpan=[4,5];
        items={labelTxt,editElem,unitElem};
        colStretch=[1,0,0,1,0];
    otherwise
        nRows=1;
        nCols=3;
        editElem.RowSpan=[1,1];
        unitElem.RowSpan=[1,1];
        editElem.ColSpan=[1,1];
        unitElem.ColSpan=[3,3];
        items={editElem,unitElem};
        colStretch=[1,1,0];
    end

    if~isempty(confElem)
        confElem.RowSpan=unitElem.RowSpan;
        confElem.ColSpan=unitElem.ColSpan+1;
        if numel(confElem.Items{1}.Entries)<2
            confElem.Items{1}.Enabled=false;
        end
        items{end+1}=confElem;
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.Tag=hThis.ObjId;
    basePanel.LayoutGrid=[nRows,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.Items=items;
    basePanel.ColStretch=colStretch;


    schema=basePanel;
end
