function dlg=getDialogSchema(obj)


    titlePanel=obj.getTitleSchema();
    titlePanel.RowSpan=[1,1];
    titlePanel.ColSpan=[1,1];

    mainPanel=obj.getMainSchema();
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,1];

    optionPanel=obj.getOptionSchema();
    optionPanel.RowSpan=[3,3];
    optionPanel.ColSpan=[1,1];




    dlg.DialogTitle='';
    dlg.Items={titlePanel,mainPanel,optionPanel};
    dlg.DialogMode='Slim';
    dlg.LayoutGrid=[4,1];
    dlg.RowStretch=[0,0,0,1];
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};

