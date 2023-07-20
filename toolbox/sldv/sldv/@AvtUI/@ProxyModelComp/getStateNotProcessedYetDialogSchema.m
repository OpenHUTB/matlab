function dstruct=getStateNotProcessedYetDialogSchema(obj,comm_widgets)

    rowIdx=1;
    items={};




    widget=[];
    widget=comm_widgets.info;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;
    rowIdx=rowIdx+1;

    rowCnt=rowIdx-1;

    panel.Name='';
    panel.Type='panel';
    panel.Items=items;
    panel.LayoutGrid=[rowCnt+1,1];
    panel.RowSpan=[1,rowCnt];
    panel.ColSpan=[1,1];
    panel.RowStretch=[zeros(1,rowCnt),1];
    panel.ColStretch=1;
    panel.Alignment=0;

    dstruct.DialogTitle='';
    dstruct.LayoutGrid=[rowCnt,1];
    dstruct.Items={panel};
    dstruct.StandaloneButtonSet={''};

end

