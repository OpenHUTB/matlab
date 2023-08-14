function[retVal,schema]=Render(hThis,~)












    retVal=true;

    renderedName=pm.sli.internal.resolveMessageString(hThis.Label);
    labelTxt.Name=[renderedName,':'];
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,1];
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,...
    hThis.ValueBlkParam);

    combo.Name=renderedName;
    combo.Type='combobox';
    combo.Tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Combo'];
    combo.HideName=hThis.HideName;
    combo.RowSpan=[1,1];
    combo.ColSpan=[1,1];
    combo.Entries={hThis.Choices{:},'<unit expression>'};
    combo.ToolTip=sprintf('<html>%s<br><b>%s</b></html>',...
    renderedName,hThis.ValueBlkParam);
    combo.Source=hThis;
    combo.ObjectProperty='Value';
    combo.Enabled=hThis.EnableStatus;
    combo.Mode=true;
    combo.ObjectMethod='notifyListeners';
    combo.MethodArgs={'%dialog','%value','%tag'};
    combo.ArgDataTypes={'handle','mxArray','string'};
    combo.Editable=true;
    combo.CaseSensitive=true;






    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=1;
        labelTxt.Alignment=4;
        items={combo};
    case 1
        nRows=1;
        nCols=3;
        combo.ColSpan=[2,3];
        items={labelTxt,combo};
    case 2
        nRows=2;
        nCols=1;
        combo.RowSpan=[2,2];
        items={labelTxt,combo};
    otherwise
        nRows=1;
        nCols=1;
        items={combo};
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.LayoutGrid=[nRows,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.RowStretch=zeros(1,nRows);
    basePanel.Items=items;

    schema=basePanel;
end
