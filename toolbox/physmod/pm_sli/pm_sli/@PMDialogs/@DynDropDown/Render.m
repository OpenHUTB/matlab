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

    combo.Name=renderedName;
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





    if numel(tmpArray)==2&&endsWith(hThis.ValueBlkParam,'_conf')
        parameter=pm.sli.internal.getMaskParameterRecursive(...
        hThis.BlockHandle.Handle,hThis.ValueBlkParam);
        pm_assert(~isempty(parameter),'Invalid Simscape block data.');
        if numel(parameter.TypeOptions)==1
            combo.Entries=tmpArray(1);
            combo.Value=tmpArray(1);
        end
    end

    combo.Enabled=hThis.EnableStatus;
    combo.ToolTip=sprintf('<html>%s<br><b>%s</b></html>',...
    renderedName,hThis.ValueBlkParam);
    combo.Source=hThis;
    combo.ObjectProperty='Value';
    combo.Mode=true;
    combo.ObjectMethod='notifyListeners';
    combo.MethodArgs={'%dialog','%value','%tag'};
    combo.ArgDataTypes={'handle','mxArray','string'};

    switch(hThis.LabelAttrb)
    case 0
        nRows=1;
        nCols=1;
        labelTxt.Alignment=4;
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
