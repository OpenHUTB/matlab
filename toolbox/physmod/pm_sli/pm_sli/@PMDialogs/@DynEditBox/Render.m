function[retVal,schema]=Render(hThis,~)












    retVal=true;

    renderedName=pm.sli.internal.resolveMessageString(hThis.Label);
    labelTxt.Name=[renderedName,':'];
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,1];
    labelTxt.WordWrap=true;
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,...
    hThis.ValueBlkParam);

    confElem=[];
    if numel(hThis.Items)>0
        if hThis.BlockHandle.getDialogSource.ShowRuntime
            [retVal,confElem]=Render(hThis.Items(1,1),confElem);
        else

            hThis.Items(end)=[];
        end
    end

    editBox.Name=renderedName;
    editBox.Type='edit';
    editBox.Tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Edit'];
    editBox.HideName=false;
    editBox.RowSpan=[1,1];
    editBox.ColSpan=[1,1];
    editBox.Value=hThis.Value;
    editBox.Enabled=hThis.EnableStatus;
    editBox.ToolTip=sprintf('<html>%s<br><b>%s</b></html>',...
    renderedName,hThis.ValueBlkParam);
    editBox.Source=hThis;
    editBox.ObjectProperty='Value';
    editBox.ObjectMethod='notifyListeners';
    editBox.MethodArgs={'%dialog','%value','%tag'};
    editBox.ArgDataTypes={'handle','mxArray','string'};

    editBox.Mode=true;
    editBox.HideName=true;

    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=1;
        colStretch=1;
        labelTxt.Alignment=4;
        items={editBox};
    case 1
        nRows=1;
        nCols=3;
        editBox.ColSpan=[2,3];
        labelTxt.ColSpan=[1,1];
        colStretch=[1,1,1];
        items={labelTxt,editBox};

    case 2
        nRows=2;
        nCols=1;
        editBox.RowSpan=[2,2];
        colStretch=1;
        items={labelTxt,editBox};
    otherwise
        nRows=1;
        nCols=1;
        colStretch=1;
        items={editBox};
    end

    if~isempty(confElem)
        confElem.RowSpan=editBox.RowSpan;
        confElem.ColSpan=editBox.ColSpan+1;
        if numel(confElem.Items{1}.Entries)<2
            confElem.Items{1}.Enabled=false;
        end
        items{end+1}=confElem;
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
