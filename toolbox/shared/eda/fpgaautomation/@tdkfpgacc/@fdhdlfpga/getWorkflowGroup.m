function group=getWorkflowGroup(this,tag,enableGroup,hParent)





    src=this.FPGAProperties;
    curRow=0;





    enableWorkflow=false;
    if isa(hParent.filterobj,'filtergroup.usrp2')
        src.FPGAWorkflow='USRP2 filter customization';
    else
        src.FPGAWorkflow='Project generation';
    end

    switch(src.FPGAWorkflow)
    case 'Project generation'
        showProjGen=true;
        showUSRP=false;
    otherwise
        showProjGen=false;
        showUSRP=true;
    end

    showProjTyp=showProjGen&&strcmpi(src.FPGAProjectGenOutput,'ISE project');
    showTclTyp=showProjGen&&strcmpi(src.FPGAProjectGenOutput,'Tcl script');
    showExist=showProjTyp&&strcmpi(src.FPGAProjectType,'Add to existing project');



    curRow=curRow+1;

    prop='FPGAWorkflow';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    FPGAWorkflowLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries={l_GetUIString(prop,'_Entries1'),...
    l_GetUIString(prop,'_Entries2')};
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableWorkflow;
    FPGAWorkflow=widget;

    FPGAWorkflowLabel.Buddy=FPGAWorkflow.Tag;


    curRow=curRow+1;


    prop='FPGAProjectGenOutput';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    widget.Visible=showProjGen;
    projectGenOutputLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries={l_GetUIString(prop,'_Entries1'),...
    l_GetUIString(prop,'_Entries2')};
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=true;
    widget.Visible=showProjGen;
    FPGAProjectGenOutput=widget;

    projectGenOutputLabel.Buddy=FPGAProjectGenOutput.Tag;


    prop='CustomFilterOutput';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    widget.Visible=showUSRP;
    CustomFilterOutputLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=true;
    widget.Visible=showUSRP;
    CustomFilterOutput=widget;

    CustomFilterOutputLabel.Buddy=CustomFilterOutput.Tag;



    prop='FPGAProjectType';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    widget.Visible=showProjTyp;
    FPGAProjectTypeLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries={l_GetUIString(prop,'_Entries1'),...
    l_GetUIString(prop,'_Entries2')};
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[4,4];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Visible=showProjTyp;
    FPGAProjectType=widget;

    FPGAProjectTypeLabel.Buddy=FPGAProjectType.Tag;


    prop='TclOptions';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    widget.Visible=showTclTyp;
    TclOptionsLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries={l_GetUIString(prop,'_Entries1'),...
    l_GetUIString(prop,'_Entries2')};
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[4,4];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Visible=showTclTyp;
    TclOptions=widget;

    TclOptionsLabel.Buddy=TclOptions.Tag;


    curRow=curRow+1;


    group=getExistingProjWidgets(this,tag,enableGroup);
    group.RowSpan=[curRow,curRow];
    group.ColSpan=[1,4];
    group.Visible=showExist;
    existGroup=group;


    group=getUSRPWidgets(this,tag,enableGroup);
    group.RowSpan=[curRow,curRow];
    group.ColSpan=[1,4];
    group.Visible=showUSRP;
    sdrGroup=group;



    gname='WorkflowGroup';

    group=[];
    group.Name=l_GetUIString(gname);
    group.Type='group';
    group.LayoutGrid=[curRow,4];
    group.ColStretch=[0,1,0,1];
    group.Tag=[tag,gname];
    group.Enabled=enableGroup;
    group.Items={FPGAWorkflowLabel,FPGAWorkflow,...
    projectGenOutputLabel,FPGAProjectGenOutput,...
    CustomFilterOutputLabel,CustomFilterOutput,...
    FPGAProjectTypeLabel,FPGAProjectType,...
    TclOptionsLabel,TclOptions,...
    existGroup,sdrGroup};


    function str=l_GetUIString(key,postfix)
        if nargin<2
            postfix='_Name';
        end
        str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);

