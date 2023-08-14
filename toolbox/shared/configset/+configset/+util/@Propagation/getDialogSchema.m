function schema=getDialogSchema(h)

    title=h.setTitle();
    title.ColSpan=[1,1];
    title.RowSpan=[1,1];

    backupInfo=h.setBackupInfo();
    backupInfo.ColSpan=[1,1];
    backupInfo.RowSpan=[3,3];

    testGroup.Type='panel';
    testGroup.RowSpan=[2,2];
    testGroup.ColSpan=[1,1];
    testGroup.Items={};

    ms=h.Map.values;
    sums=0;
    csum=0;
    for i=1:h.Number
        m=ms{i};
        sums=sums+m.IsSelected;
        csum=csum+strcmp(m.Status,'Converted');
        mdlg=m.getSchema();
        testGroup.Items{end+1}=mdlg;
    end

    topPan.Type='panel';
    topPan.LayoutGrid=[1,8];
    topPan.ColStretch=[0,5,1,3,2,3,1,1];
    topPan.BackgroundColor=[200,200,200];
    index=0;

    checkon.Type='image';
    checkon.Tag='checkon';
    checkon.Visible=(sums==h.Number);
    checkon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','checkbox_on.png');
    checkon.RowSpan=[1,1];
    checkon.ColSpan=[1,1];
    checkon.ObjectMethod='checkon';
    checkon.MaximumSize=[16,16];
    checkon.MinimumSize=[16,16];
    index=index+1;
    topPan.Items{index}=checkon;

    checkon.Type='image';
    checkon.Tag='checkoff';
    checkon.Visible=(sums==0);
    checkon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','checkbox_off.png');
    checkon.RowSpan=[1,1];
    checkon.ColSpan=[1,1];
    checkon.ObjectMethod='checkoff';
    checkon.MaximumSize=[16,16];
    checkon.MinimumSize=[16,16];
    index=index+1;
    topPan.Items{index}=checkon;

    checkon.Type='image';
    checkon.Tag='checktri';
    checkon.Visible=(sums<h.Number&&sums>0);
    checkon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','checkbox_tristate.png');
    checkon.RowSpan=[1,1];
    checkon.ColSpan=[1,1];
    checkon.ObjectMethod='checktri';
    checkon.MaximumSize=[16,16];
    checkon.MinimumSize=[16,16];
    index=index+1;
    topPan.Items{index}=checkon;

    ModelT=h.setCell('text',...
    DAStudio.message('configset:util:TopPan_Model',sums,h.Number),...
    'Model',...
    1,2);
    ModelT.Bold=true;
    ModelT.Alignment=5;


    index=index+1;
    topPan.Items{index}=ModelT;

    statusT=h.setCell('text',...
    DAStudio.message('configset:util:TopPan_Status'),...
    'Status',...
    1,3);
    statusT.Bold=true;
    statusT.Alignment=6;
    statusT.RowSpan=[1,1];
    statusT.ColSpan=[3,4];



    index=index+1;
    topPan.Items{index}=statusT;

    detailsT=h.setCell('text',...
    DAStudio.message('configset:util:TopPan_Difference'),...
    'Details',...
    1,4);
    detailsT.RowSpan=[1,1];
    detailsT.ColSpan=[5,6];
    detailsT.Bold=true;
    detailsT.Alignment=6;


    index=index+1;
    topPan.Items{index}=detailsT;

    undoT=h.setCell('text',...
    strcat(DAStudio.message('configset:util:TopPan_Undo'),...
    '/',...
    DAStudio.message('configset:util:TopPan_Redo')),...
    'Undo/Redo',...
    1,5);
    undoT.RowSpan=[1,1];
    undoT.ColSpan=[7,8];
    undoT.Bold=true;
    undoT.Alignment=6;


    index=index+1;
    topPan.Items{index}=undoT;

    modelGroup.Type='group';
    modelGroup.Tag='ModelGroup';

    modelGroup.Items={topPan,testGroup};
    modelGroup.RowSpan=[5,5];
    modelGroup.ColSpan=[1,1];

    main.Type='panel';
    main.Tag='main';
    main.LayoutGrid=[6,1];
    main.RowStretch=[0,0,0,0,0,1];
    main.Items={title,backupInfo,modelGroup};


    bottomPan=getBottomPanSchema(h,sums,csum);

    schema.DialogTitle=DAStudio.message('configset:util:DialogTitle');
    schema.DialogTag='PropagationDialog';
    schema.LayoutGrid=[2,2];
    schema.RowStretch=[0,1];
    schema.ColStretch=[0,1];
    schema.Items={main};
    schema.CloseMethod='closeAll';
    schema.StandaloneButtonSet=bottomPan;
    schema.Geometry=[100,100,800,480];
