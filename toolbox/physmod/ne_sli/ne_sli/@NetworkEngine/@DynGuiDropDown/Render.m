function[retVal,schema]=Render(hThis,~)











    retVal=true;

    label=hThis.Label;
    labelTxt.Name=[label,':'];
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,1];
    labelTxt.WordWrap=true;
    labelTxt.Tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'_label.Text'];

    combo.Name=[label,':'];
    combo.Type='combobox';
    combo.Tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Combo'];
    combo.HideName=true;
    combo.RowSpan=[1,1];
    combo.ColSpan=[1,1];


    tmpArray=hThis.Choices;
    if(ismatrix(tmpArray)&&size(tmpArray,1)~=1)
        tmpArray=reshape(hThis.Choices,1,size(hThis.Choices,1));
    end

    combo.Entries=tmpArray;
    combo.Value=hThis.Value;
    combo.Enabled=hThis.EnableStatus;
    combo.ToolTip=sprintf('<html>%s<br><b>%s</b></html>',label,hThis.ValueBlkParam);
    combo.Source=hThis;
    combo.ObjectProperty='Value';
    combo.Mode=true;
    combo.ObjectMethod='OnDropDownChange';
    combo.MethodArgs={'%source','%dialog','%value','%tag'};
    combo.ArgDataTypes={'handle','handle','mxArray','string'};

    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=1;
        items={combo};
        colStretchData=1;
    case 1
        nRows=1;
        nCols=3;
        combo.ColSpan=[2,3];
        items={labelTxt,combo};
        colStretchData=[1,1,1];
    case 2
        nRows=2;
        nCols=1;
        combo.RowSpan=[2,2];
        items={labelTxt,combo};
        colStretchData=1;
    otherwise
        nRows=1;
        nCols=1;
        colStretchData=1;
        items={combo};
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.LayoutGrid=[nRows,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.Items=items;
    basePanel.ColStretch=colStretchData;
    basePanel.RowStretch=zeros(1,nRows);

    schema=basePanel;
end
