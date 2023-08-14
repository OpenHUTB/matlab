function dstruct=getDialogSchemaNotAnalysable(obj,comm_widgets)
    tag='ComponentAdv_SLDV_NotAnalysable';
    rowIdx=1;
    items={};



    widget=[];
    widget=comm_widgets.info;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,2];
    items{end+1}=widget;
    rowIdx=rowIdx+1;


    widget=[];
    widget=comm_widgets.dl_label;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,2];
    items{end+1}=widget;
    rowIdx=rowIdx+1;


    widget=[];
    widget=comm_widgets.dl_link;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,2];
    items{end+1}=widget;
    rowIdx=rowIdx+1;


    widget=[];
    widget=comm_widgets.comp_summary;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,2];
    items{end+1}=widget;
    rowIdx=rowIdx+1;



    widget=[];
    widget=comm_widgets.tgres_label;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;



    widget=[];
    widget=comm_widgets.tgres_link;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[2,2];
    widget.MatlabMethod='dialogCallback';
    widget.MatlabArgs={obj,'load_tg_results'};
    items{end+1}=widget;
    rowIdx=rowIdx+1;



    widget=[];
    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:RecheckTime');
    widget.Type='edit';
    widget.Tag=[tag,'_','RecheckTime'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[1,1];
    items{end+1}=widget;



    widget=[];
    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:Recheck');
    widget.Type='pushbutton';
    widget.Tag=[tag,'_','ButtonToRecheck'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[2,2];
    widget.MatlabMethod='dialogCallback';
    widget.MatlabArgs={obj,'recheck'};
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

