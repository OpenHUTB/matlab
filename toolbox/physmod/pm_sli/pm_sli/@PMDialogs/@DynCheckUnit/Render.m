function[retVal,schema]=Render(hThis,schema)












    retVal=true;

    labelTxt.Name=hThis.Label;
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,3];
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,...
    hThis.Items(1,1).ValueBlkParam);


    hThis.Items(1,1).BuddyItems=[hThis.Items(2,1)];




    chkElem=[];
    [retVal,chkElem]=hThis.Items(1,1).Render(chkElem);

    unitElem=[];
    [retVal,unitElem]=Render(hThis.Items(2,1),unitElem);
    if(hThis.Items(1,1).Value==false)
        unitElem.Items{1,1}.Enabled=false;
    end

    chkElem.RowSpan=[1,1];
    chkElem.ColSpan=[1,1];
    unitElem.RowSpan=[1,1];
    unitElem.ColSpan=[2,2];

    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=2;
        chkElem.RowSpan=[1,1];
        chkElem.ColSpan=[1,1];
        unitElem.RowSpan=[1,1];
        unitElem.ColSpan=[2,2];
        items={chkElem,unitElem};
        colStretch=[1,1];
    case 1
        nRows=1;
        nCols=6;
        chkElem.RowSpan=[1,1];
        chkElem.ColSpan=[2,4];
        unitElem.RowSpan=[1,1];
        unitElem.ColSpan=[5,6];
        labelTxt.ColSpan=[1,1];
        items={chkElem,unitElem,labelTxt};
        colStretch=[0,1,1,1,0,0];
    case 2
        nRows=2;
        nCols=5;
        labelTxt.ColSpan=[1,5];
        chkElem.RowSpan=[2,2];
        chkElem.ColSpan=[1,3];
        unitElem.RowSpan=[2,2];
        unitElem.ColSpan=[4,5];
        items={labelTxt,chkElem,unitElem};
        colStretch=[1,1,1,1,0];
    otherwise
        nRows=1;
        nCols=3;
        chkElem.RowSpan=[1,1];
        unitElem.RowSpan=[1,1];
        chkElem.ColSpan=[1,1];
        unitElem.ColSpan=[3,3];
        items={chkElem,unitElem};
        colStretch=[1,1,0];
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.Tag=hThis.ObjId;
    basePanel.LayoutGrid=[nRows,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.Items=items;
    basePanel.ColStretch=colStretch;
    basePanel.RowStretch=zeros(1,nRows);


    schema=basePanel;
end
