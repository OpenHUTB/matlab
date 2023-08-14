function dlgstruct=getDialogSchema(obj,s)
    widget.Type='pushbutton';
    widget.Name='&OK';
    widget.Tag='ModelDDLinks_OK';
    widget.MatlabMethod='slprivate';
    widget.MatlabArgs={'ModelDDLinks_cb',obj,'%dialog','','OK'};
    widget.Enabled=true;
    okbutton=widget;

    okbutton.RowSpan=[1,1];
    okbutton.ColSpan=[2,2];

    widget.Type='pushbutton';
    widget.Name='&Cancel';
    widget.Tag='ModelDDLinks_Cancel';
    widget.MatlabMethod='slprivate';
    widget.MatlabArgs={'ModelDDLinks_cb',obj,'%dialog','','Cancel'};
    widget.Enabled=true;
    cancelbutton=widget;

    cancelbutton.RowSpan=[1,1];
    cancelbutton.ColSpan=[3,3];

    widget.Type='pushbutton';
    widget.Name='&Help';
    widget.Tag='ModelDDLinks_Help';
    widget.MatlabMethod='slprivate';
    widget.MatlabArgs={'ModelDDLinks_cb',obj,'%dialog','','Help'};
    widget.Enabled=true;
    helpbutton=widget;

    helpbutton.RowSpan=[1,1];
    helpbutton.ColSpan=[4,4];

    widget.Type='pushbutton';
    widget.Name='&Apply';
    widget.Tag='ModelDDLinks_Apply';
    widget.MatlabMethod='slprivate';
    widget.MatlabArgs={'ModelDDLinks_cb',obj,'%dialog','','Apply'};
    widget.Enabled=false;
    applybutton=widget;

    applybutton.RowSpan=[1,1];
    applybutton.ColSpan=[5,5];

    filler.Type='text';
    filler.Name='';
    filler.Tag='ModelDDLinks_filler';
    filler.RowSpan=[1,1];
    filler.ColSpan=[1,1];

    panel.Type='panel';
    panel.Tag='ModelDDLinks_panel';
    panel.Items={filler,okbutton,cancelbutton,helpbutton,applybutton};
    panel.Visible=true;
    panel.LayoutGrid=[1,5];
    panel.ColStretch=[1,0,0,0,0];





    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag='_ui';
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.IsScrollable=false;
    dlgstruct.Items={panel};
    dlgstruct.SmartApply=0;
    dlgstruct.PreApplyCallback='slprivate';
    dlgstruct.PreApplyArgs={'ModelDDLinks_DlgAction','%dialog','hHostController','apply',''};

end
