function[retVal,schema]=Render(hThis,schema)












    retVal=true;

    labelTxt.Name=hThis.Label;
    labelTxt.Type='text';
    labelTxt.RowSpan=[1,1];
    labelTxt.ColSpan=[1,1];
    labelTxt.Tag=sprintf('%s.%s_label.Text',hThis.ObjId,...
    hThis.ValueBlkParam);






    hThis.ValueTxt=num2str(hThis.Value);
    baseTagName=[hThis.ObjId,'.',hThis.ValueBlkParam];

    textbox.Name=hThis.Label;
    textbox.Type='edit';
    textbox.Tag=[baseTagName,'.Edit'];
    textbox.Value=hThis.Value;
    textbox.Enabled=hThis.EnableStatus;
    textbox.RowSpan=[1,1];
    textbox.ColSpan=[1,1];
    textbox.Mode=true;
    textbox.Source=hThis;
    textbox.ObjectProperty='ValueTxt';
    textbox.HideName=true;
    textbox.ObjectMethod='OnEditChange';
    textbox.MethodArgs={'%dialog','%value','%tag'};
    textbox.ArgDataTypes={'handle','string','string'};

    txtPanel.Name='';
    txtPanel.Type='panel';
    txtPanel.LayoutGrid=[1,1];
    txtPanel.RowSpan=[1,1];
    txtPanel.ColSpan=[1,8];
    txtPanel.Items={textbox};
    txtPanel.Source=hThis;
    txtPanel.RowStretch=0;
    txtPanel.ColStretch=0;

    buttonSize=[15,15];

    upButn.FilePath=fullfile(pmsl_dialogresourcedir,'spinner_arrow_up.png');
    upButn.Name='';
    upButn.Tag=[baseTagName,'.UpButton'];
    upButn.Type='pushbutton';
    upButn.Enabled=hThis.EnableStatus;
    upButn.RowSpan=[1,1];
    upButn.ColSpan=[1,1];
    upButn.MinimumSize=buttonSize;
    upButn.MaximumSize=buttonSize;
    upButn.ObjectMethod='OnUpButton';
    upButn.MethodArgs={'%dialog','%tag'};
    upButn.ArgDataTypes={'handle','string'};
    upButn.Alignment=1;

    downButn.Name='';
    downButn.Type='pushbutton';
    downButn.Enabled=hThis.EnableStatus;
    downButn.Tag=[baseTagName,'.DownButton'];
    downButn.FilePath=fullfile(matlabroot,'toolbox','physmod',...
    'pm_sli','pm_sli','dlg_resources','spinner_arrow_down.png');
    downButn.RowSpan=[2,2];
    downButn.ColSpan=[1,1];
    downButn.MinimumSize=buttonSize;
    downButn.MaximumSize=buttonSize;
    downButn.ObjectMethod='OnDownButton';
    downButn.MethodArgs={'%dialog','%tag'};
    downButn.ArgDataTypes={'handle','string'};
    downButn.Alignment=1;

    butnPanel.Name='';
    butnPanel.Type='panel';
    butnPanel.LayoutGrid=[2,1];
    butnPanel.RowSpan=[1,1];
    butnPanel.ColSpan=[9,9];
    butnPanel.RowStretch=[0,0];
    butnPanel.ColStretch=0;
    butnPanel.Alignment=4;
    butnPanel.Items={upButn,downButn};
    butnPanel.Source=hThis;

    panel.Name='';
    panel.Type='panel';
    panel.LayoutGrid=[1,10];
    panel.RowSpan=[1,1];
    panel.ColSpan=[1,1];
    panel.RowStretch=0;
    panel.ColStretch=zeros(1,10);
    panel.Alignment=4;

    panel.Items={txtPanel,butnPanel};
    panel.Source=hThis;

    if(~isempty(hThis.Label))
        nCols=2;
        panel.ColSpan=[2,2];
        itemList={labelTxt,panel};
    else
        nCols=1;
        panel.ColSpan=[1,1];
        itemList={panel};
    end

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.LayoutGrid=[1,nCols];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.Items=itemList;
    basePanel.ColStretch=zeros(1,nCols);
    basePanel.RowStretch=0;

    schema=basePanel;
end
