function viewPnl=createOpenButton(blockPath,message,dlgType)











    txt.Type='text';
    txt.Tag='OpenMessage';
    txt.Name=DAStudio.message(message);
    txt.WordWrap=1;
    txt.RowSpan=[1,1];

    spacer.Type='panel';
    spacer.Enabled=false;

    btn.Type='pushbutton';
    btn.Tag='OpenButton';
    btn.Name=DAStudio.message('dastudio:propertyinspector:OpenParamDialog');
    btn.MatlabMethod='open_system';
    btn.MatlabArgs={blockPath,dlgType};
    btn.RowSpan=[1,1];
    btn.ColSpan=[2,2];

    btnPnl.Type='panel';
    btnPnl.Items={spacer,btn,spacer};
    btnPnl.LayoutGrid=[1,3];
    btnPnl.ColStretch=[1,0,1];
    btnPnl.RowSpan=[2,2];

    viewPnl.Type='panel';
    viewPnl.Items={txt,btnPnl};
    viewPnl.LayoutGrid=[2,1];

end

