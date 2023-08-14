function dstruct=getDialogSchemaIncompatibility(obj,comm_widgets)
    tag='ComponentAdv_SLDV_Incompatibility';
    rowIdx=1;
    items={};


    widget=[];
    widget=comm_widgets.info;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;
    rowIdx=rowIdx+1;



    widget=[];
    widget=comm_widgets.comp_summary;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;
    rowIdx=rowIdx+1;



    widget=[];
    widget.Name='';
    widget.Type='textbrowser';
    widget.Tag=[tag,'_','Incompatibility'];
    widget.Text=obj.incompatMsg;
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;
    rowIdx=rowIdx+1;



    rowCnt=rowIdx-1;

    panel.Name='Display Attributes';
    panel.Type='panel';
    panel.Items=items;
    panel.LayoutGrid=[rowCnt+1,1];
    panel.RowSpan=[1,rowCnt];
    panel.ColSpan=[1,1];
    panel.RowStretch=[zeros(1,rowCnt),1];
    panel.ColStretch=1;
    panel.Alignment=0;

    dstruct.DialogTitle=obj.label;
    dstruct.LayoutGrid=[rowCnt,1];
    dstruct.Items={panel};
    dstruct.StandaloneButtonSet={''};


end

