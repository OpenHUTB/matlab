function dlgStruct=getDialogSchema(this,~)










    blkh=this.Block.Handle;
    maskEnables=get_param(blkh,'MaskEnables');
    oldMaskEnables=maskEnables;
    idxIsReset=3;
    idxH=8;






    num_targets=dspGetLeafWidgetBase('edit',...
    'Number of filters:','num_targets',this,'num_targets');
    num_targets.Entries=set(this,'num_targets')';
    num_targets.DialogRefresh=1;
    num_targets.Tunable=0;
    num_targets.RowSpan=[1,1];
    num_targets.ColSpan=[1,3];


    sourceEnable=dspGetLeafWidgetBase('combobox',...
    'Enable filters:      ','sourceEnable',...
    this,'sourceEnable');
    sourceEnable.Entries=set(this,'sourceEnable')';
    sourceEnable.DialogRefresh=1;
    sourceEnable.Tunable=0;
    sourceEnable.RowSpan=[2,2];
    sourceEnable.ColSpan=[1,3];




    indent1=dspGetLeafWidgetBase('text',' ','indent1',0);
    indent1.MinimumSize=[24,0];
    indent1.MaximumSize=[24,24];
    indent1.RowSpan=[3,3];
    indent1.ColSpan=[1,1];


    isReset=dspGetLeafWidgetBase('checkbox',...
    'Reset estimated state and estimated error covariance when filters are disabled',...
    'isReset',this,'isReset');
    isReset.Entries=set(this,'isReset')';
    isReset.DialogRefresh=1;
    isReset.Tunable=0;
    isReset.RowSpan=[3,3];
    isReset.ColSpan=[2,3];



    separatorPane=dspGetContainerWidgetBase('group','','separatorPane');
    separatorPane.RowSpan=[4,4];
    separatorPane.ColSpan=[1,3];
    separatorPane.Flat=1;


    X=dspGetLeafWidgetBase('edit',...
    'Initial condition for estimated state:                       ','X',this,'X');
    X.Entries=set(this,'X')';
    X.Tunable=0;
    X.RowSpan=[5,5];
    X.ColSpan=[1,3];


    P=dspGetLeafWidgetBase('edit',...
    'Initial condition for estimated error covariance:',...
    'P',this,'P');
    P.Entries=set(this,'P')';
    P.Tunable=0;
    P.RowSpan=[6,6];
    P.ColSpan=[1,3];


    A=dspGetLeafWidgetBase('edit',...
    'State transition matrix:                     ','A',this,'A');
    A.Entries=set(this,'A')';
    A.Tunable=0;
    A.RowSpan=[7,7];
    A.ColSpan=[1,3];


    Q=dspGetLeafWidgetBase('edit',...
    'Process noise covariance:           ','Q',this,'Q');
    Q.Entries=set(this,'Q')';
    Q.Tunable=0;
    Q.RowSpan=[8,8];
    Q.ColSpan=[1,3];


    sourceMeasure=dspGetLeafWidgetBase('combobox',...
    'Measurement matrix source:        ','sourceMeasure',...
    this,'sourceMeasure');
    sourceMeasure.Entries=set(this,'sourceMeasure')';
    sourceMeasure.DialogRefresh=1;
    sourceMeasure.Tunable=0;
    sourceMeasure.RowSpan=[9,9];
    sourceMeasure.ColSpan=[1,3];


    indent2=dspGetLeafWidgetBase('text',' ','indent2',0);
    indent2.MinimumSize=[24,0];
    indent2.MaximumSize=[24,24];
    indent2.RowSpan=[10,10];
    indent2.ColSpan=[1,1];


    H=dspGetLeafWidgetBase('edit',...
    'Measurement matrix:              ','H',this,'H');
    H.Entries=set(this,'H')';
    H.Tunable=0;
    H.RowSpan=[10,10];
    H.ColSpan=[2,3];


    R=dspGetLeafWidgetBase('edit',...
    'Measurement noise covariance:','R',this,'R');
    R.Entries=set(this,'R')';
    R.Tunable=0;
    R.RowSpan=[11,11];
    R.ColSpan=[1,3];


    isOutputEstMeasure=dspGetLeafWidgetBase('checkbox',...
    'Output estimated measurement <Z_est>',...
    'isOutputEstMeasure',this,'isOutputEstMeasure');
    isOutputEstMeasure.Entries=set(this,'isOutputEstMeasure')';
    isOutputEstMeasure.Tunable=0;
    isOutputEstMeasure.RowSpan=[12,12];
    isOutputEstMeasure.ColSpan=[1,2];


    isOutputPrdMeasure=dspGetLeafWidgetBase('checkbox',...
    'Output predicted measurement <Z_prd>',...
    'isOutputPrdMeasure',this,'isOutputPrdMeasure');
    isOutputPrdMeasure.Entries=set(this,'isOutputPrdMeasure')';
    isOutputPrdMeasure.Tunable=0;
    isOutputPrdMeasure.RowSpan=[12,12];
    isOutputPrdMeasure.ColSpan=[3,3];


    isOutputEstState=dspGetLeafWidgetBase('checkbox',...
    'Output estimated state <X_est>',...
    'isOutputEstState',this,'isOutputEstState');
    isOutputEstState.Entries=set(this,'isOutputEstState')';
    isOutputEstState.Tunable=0;
    isOutputEstState.RowSpan=[13,13];
    isOutputEstState.ColSpan=[1,2];


    isOutputPrdState=dspGetLeafWidgetBase('checkbox',...
    'Output predicted state <X_prd>',...
    'isOutputPrdState',this,'isOutputPrdState');
    isOutputPrdState.Entries=set(this,'isOutputPrdState')';
    isOutputPrdState.Tunable=0;
    isOutputPrdState.RowSpan=[13,13];
    isOutputPrdState.ColSpan=[3,3];


    isOutputEstError=dspGetLeafWidgetBase('checkbox',...
    'Output MSE of estimated state <MSE_est>',...
    'isOutputEstError',this,'isOutputEstError');
    isOutputEstError.Entries=set(this,'isOutputEstError')';
    isOutputEstError.Tunable=0;
    isOutputEstError.RowSpan=[14,14];
    isOutputEstError.ColSpan=[1,2];


    isOutputPrdError=dspGetLeafWidgetBase('checkbox',...
    'Output MSE of predicted state <MSE_prd>',...
    'isOutputPrdError',this,'isOutputPrdError');
    isOutputPrdError.Entries=set(this,'isOutputPrdError')';
    isOutputPrdError.Tunable=0;
    isOutputPrdError.RowSpan=[14,14];
    isOutputPrdError.ColSpan=[3,3];


    if strcmp(this.sourceEnable,'Always')
        indent1.Visible=0;
        isReset.Visible=0;
        maskEnables{idxIsReset}='off';
    else
        indent1.Visible=1;
        isReset.Visible=1;
        maskEnables{idxIsReset}='on';
    end


    if strcmp(this.sourceMeasure,'Specify via dialog')
        indent2.Visible=1;
        H.Visible=1;
        maskEnables{idxH}='on';
    else
        indent2.Visible=0;
        H.Visible=0;
        maskEnables{idxH}='off';
    end


    parameterPane=dspGetContainerWidgetBase('group','Parameters','parameterPane');
    parameterPane.Tag='parameterPane';
    parameterPane.Items=dspTrimItemList(...
    {num_targets,sourceEnable,indent1,isReset,...
    separatorPane,X,P,A,Q,sourceMeasure,indent2,H,R});
    parameterPane.RowSpan=[1,1];
    parameterPane.ColSpan=[1,1];
    parameterPane.LayoutGrid=[1,1];


    outputPane=dspGetContainerWidgetBase('group','Outputs','outputPane');
    outputPane.Tag='outputPane';
    outputPane.Items=dspTrimItemList(...
    {isOutputEstState,isOutputEstMeasure,isOutputEstError,...
    isOutputPrdState,isOutputPrdMeasure,isOutputPrdError});
    outputPane.RowSpan=[2,2];
    outputPane.ColSpan=[1,1];
    outputPane.LayoutGrid=[1,1];


    wholePane=dspGetContainerWidgetBase('panel','','');
    wholePane.Tag='wholePane';
    wholePane.Items=dspTrimItemList({parameterPane,outputPane});
    wholePane.RowSpan=[2,2];
    wholePane.ColSpan=[1,1];
    wholePane.LayoutGrid=[1,1];

    dlgStruct=getBaseSchemaStruct(this,wholePane);
    dlgStruct.DialogTitle=this.Block.Name;


    if(~isequal(maskEnables,oldMaskEnables))
        set_param(blkh,'MaskEnables',maskEnables);
    end


