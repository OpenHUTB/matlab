function[retVal,schema]=Render(hThis,schema)












    retVal=true;

    labelTxt.Name=hThis.Label;
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,1];
    labelTxt.WordWrap=true;
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,hThis.Label);

    displayBox.Name=hThis.Label;
    displayBox.Type='edit';
    displayBox.Tag=[hThis.ObjId,'.',hThis.Label,'.Display'];
    displayBox.HideName=false;
    displayBox.RowSpan=[1,1];
    displayBox.ColSpan=[1,1];
    displayBox.Value=hThis.Value;
    displayBox.Enabled=false;
    displayBox.ToolTip=hThis.Label;
    displayBox.HideName=true;

    switch(hThis.LabelAttrb)
    case 1
        nRows=1;
        nCols=3;
        displayBox.ColSpan=[2,3];
        labelTxt.ColSpan=[1,1];
        colStretch=[1,1,1];
        items={labelTxt,displayBox};
    case 2
        nRows=1;
        nCols=1;
        colStretch=1;
        items={labelTxt};
    otherwise
        nRows=1;
        nCols=1;
        colStretch=1;
        labelTxt.Alignment=4;
        items={displayBox};
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.LayoutGrid=[nRows,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    if(exist('colStretch','var')&&~isempty(colStretch))
        basePanel.ColStretch=colStretch;
    end
    basePanel.Items=items;

    schema=basePanel;
end
