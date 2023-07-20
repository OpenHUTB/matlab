function fpgaPanel=getTabDialogSchema(this,hParent,schemaName)




    componentname='FPGAWorkflowPanel_';
    tagpf=[hParent.getproductname,componentname];

    enableGroup=strcmpi(hParent.CLIProperties.EnableFPGAWorkflow,'on');

    curRow=0;


    curRow=curRow+1;

    widget=[];
    widget.Name=DAStudio.message('EDALink:FPGAUI:EnableFPGAWorkflow_Name');
    widget.Type='checkbox';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,2];
    widget.Source=hParent.CLIProperties;
    widget.ObjectProperty='EnableFPGAWorkflow';
    widget.Tag=[tagpf,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;


    curRow=curRow+1;

    group=getWorkflowGroup(this,tagpf,enableGroup,hParent);
    group.RowSpan=[curRow,curRow];
    group.ColSpan=[1,2];
    wfGroup=group;


    curRow=curRow+1;

    group=getProjSettingsGroup(this,tagpf,enableGroup);
    group.RowSpan=[curRow,curRow];
    group.ColSpan=[1,2];
    prjGroup=group;


    curRow=curRow+1;

    group=getClockGroup(this,tagpf,enableGroup);
    group.RowSpan=[curRow,curRow];
    group.ColSpan=[1,2];
    clkGroup=group;

    items={widget,wfGroup,prjGroup,clkGroup};

    if strcmpi(schemaName,'tab')
        fpgaPanel.Items=items;
    else
        fpgaPanel.Type='panel';
        fpgaPanel.Items=items;
    end

    fpgaPanel.LayoutGrid=[curRow+1,4];
    fpgaPanel.RowStretch=[zeros(1,curRow),1];

    fpgaPanel.Name=DAStudio.message('HDLShared:fdhdldialog:fdhdlfpgaComponentName');

