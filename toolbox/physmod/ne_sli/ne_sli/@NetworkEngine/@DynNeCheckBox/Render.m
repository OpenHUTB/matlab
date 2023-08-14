function[retVal,schema]=Render(hThis,~)











    retVal=true;
    chkBox.Name=hThis.Label;
    chkBox.Type='checkbox';
    chkBox.Tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Check'];
    chkBox.HideName=false;
    chkBox.RowSpan=[1,1];
    chkBox.ColSpan=[1,1];
    chkBox.Value=hThis.Value;
    chkBox.Enabled=hThis.EnableStatus;
    chkBox.ToolTip=hThis.Label;
    chkBox.Source=hThis;
    chkBox.ObjectProperty='Value';
    chkBox.Mode=true;
    chkBox.ObjectMethod='OnCheckBoxChange';
    chkBox.MethodArgs={'%source','%dialog','%value','%tag'};
    chkBox.ArgDataTypes={'handle','handle','mxArray','string'};

    if(hThis.LabelAttrb~=0)
        chkBox.HideName=true;
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.LayoutGrid=[1,1];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.RowStretch=0;
    basePanel.Items={chkBox};

    schema=basePanel;
end
