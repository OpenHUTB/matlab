function dstruct=getDialogSchemaAnalysable(obj,comm_widgets)




    tag='ComponentAdv_SLDV_Analysable';
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

    temp_options_desc=['<html><body><p> Recommended SLDV Options : <br> Test Suite Optimization: Auto <br>'...
    ,'Maximum Testcase Steps:  500time steps <br>'...
    ,'Test Conditions: UseLocalSettings <br>'...
    ,'Test Objectives: UseLocalSettings <br>'...
    ,'Include expected output values: off </p></body></html>'];


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
    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:RunSldvTestGen');
    widget.Type='pushbutton';
    widget.Tag=[tag,'_','ButtonToRunTestGen'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowIdx;
    widget.ColSpan=[2,2];
    widget.MatlabMethod='dialogCallback';
    widget.MatlabArgs={obj,'run_tg'};
    items{end+1}=widget;
    rowIdx=rowIdx+1;


    rowCnt=rowIdx-1;

    panel.Name='Display Attributes';
    panel.Type='panel';
    panel.Items=items;
    panel.LayoutGrid=[rowCnt+1,1];
    panel.RowSpan=[1,rowCnt];
    panel.ColSpan=[1,2];
    panel.RowStretch=[zeros(1,rowCnt),1];
    panel.ColStretch=1;
    panel.Alignment=0;

    dstruct.DialogTitle=obj.label;
    dstruct.LayoutGrid=[rowCnt,2];
    dstruct.Items={panel};
    dstruct.StandaloneButtonSet={''};

end

