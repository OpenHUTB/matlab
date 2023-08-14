function EnableHWBufferWidget=getEnableHWBufferWidget(this)




    EnableHWBufferChkBox.Name=this.getCatalogMsgStr('EnableHWBuffer_Text');
    EnableHWBufferChkBox.Tag='edaEnableHWBufferChkBox';
    EnableHWBufferChkBox.Type='checkbox';
    EnableHWBufferChkBox.RowSpan=[1,1];
    EnableHWBufferChkBox.ColSpan=[1,1];
    EnableHWBufferChkBox.Source=this;
    EnableHWBufferChkBox.ObjectProperty='EnableHWBuffer';
    EnableHWBufferChkBox.ObjectMethod='onChangeEnableHWBuffer';
    EnableHWBufferChkBox.Mode=true;

    EnableHWBufferWidget.Type='panel';
    EnableHWBufferWidget.Tag='edaEnableHWBufferPanel';
    EnableHWBufferWidget.LayoutGrid=[1,1];
    EnableHWBufferWidget.RowSpan=[4,4];
    EnableHWBufferWidget.ColSpan=[1,1];

    EnableHWBufferWidget.Items={EnableHWBufferChkBox};

end
