function dlgStruct=getDialogSchema(this,dummy)












    descr.Type='text';
    descr.Name=this.Block.MaskDescription;
    descr.Tag='descriptionText';
    descr.WordWrap=1;




    descrGroup.Type='group';
    descrGroup.Name=this.Block.MaskType;
    descrGroup.Tag='descriptionGroup';
    descrGroup.Items={descr};







    fnText.Type='text';
    fnText.Name='VCD file name:';
    fnText.Tag='fnText';
    fnText.RowSpan=[2,2];
    fnText.ColSpan=[1,1];

    fnEdit.Type='edit';
    fnEdit.Tag='FileName';
    fnEdit.MatlabMethod='cosimDDGSync';
    fnEdit.MatlabArgs={this,'%dialog','%tag'};
    fnEdit.ObjectProperty='FileName';
    fnEdit.Mode=1;
    fnEdit.Tunable=0;
    fnEdit.Alignment=5;
    fnEdit.RowSpan=[3,3];
    fnEdit.ColSpan=[1,1];





    inportText.Type='text';
    inportText.Name='Number of input ports:';
    inportText.Tag='fnText';
    inportText.RowSpan=[5,5];
    inportText.ColSpan=[1,1];

    inportEdit.Type='edit';
    inportEdit.Tag='NumInport';
    inportEdit.MatlabMethod='cosimDDGSync';
    inportEdit.MatlabArgs={this,'%dialog','%tag'};
    inportEdit.ObjectProperty='NumInport';
    inportEdit.Mode=1;
    inportEdit.Tunable=0;
    inportEdit.Alignment=5;
    inportEdit.RowSpan=[5,5];
    inportEdit.ColSpan=[2,2];












    fillerRow1Label.Type='text';
    fillerRow1Label.Name='';
    fillerRow1Label.Tag='fillerRow1Label';
    fillerRow1Label.Mode=1;
    fillerRow1Label.Tunable=0;
    fillerRow1Label.Alignment=5;

    oneSecLabel.Type='text';
    oneSecLabel.Name='1 second in Simulink corresponds to';
    oneSecLabel.Tag='OneSecLabel';
    oneSecLabel.Mode=1;
    oneSecLabel.Tunable=0;
    oneSecLabel.RowSpan=[2,2];
    oneSecLabel.ColSpan=[1,1];
    oneSecLabel.Alignment=5;




    timingScaleFactor.Type='edit';
    timingScaleFactor.Tag='TimingScaleFactor';
    timingScaleFactor.MatlabMethod='cosimDDGSync';
    timingScaleFactor.MatlabArgs={this,'%dialog','%tag'};
    timingScaleFactor.ObjectProperty='TimingScaleFactor';
    timingScaleFactor.Mode=1;
    timingScaleFactor.Tunable=0;
    timingScaleFactor.RowSpan=[2,2];
    timingScaleFactor.ColSpan=[2,2];
    timingScaleFactor.Alignment=5;


    timingMode.Type='combobox';
    timingMode.Tag='TimingMode';
    timingMode.Name='';
    timingMode.MatlabMethod='cosimDDGSync';
    timingMode.MatlabArgs={this,'%dialog','%tag'};
    timingMode.ObjectProperty='TimingMode';
    timingMode.Entries=set(this,'TimingMode').';
    timingMode.Mode=1;
    timingMode.Tunable=0;
    timingMode.RowSpan=[2,2];
    timingMode.ColSpan=[3,3];
    timingMode.Alignment=5;


    modLabel.Type='text';
    modLabel.Name='in the HDL simulator';
    modLabel.Tag='modLabel';
    modLabel.Mode=1;
    modLabel.Tunable=0;
    modLabel.RowSpan=[2,2];
    modLabel.ColSpan=[4,4];
    modLabel.Alignment=5;




    tickText.Type='text';
    tickText.Name='1 HDL tick is defined as ';
    tickText.Tag='tickText';
    tickText.Mode=1;
    tickText.Tunable=0;
    tickText.RowSpan=[4,4];
    tickText.ColSpan=[1,1];
    tickText.Alignment=5;




    tickScale.Type='combobox';
    tickScale.Tag='HdlTickScale';
    tickScale.MatlabMethod='cosimDDGSync';
    tickScale.MatlabArgs={this,'%dialog','%tag'};
    tickScale.ObjectProperty='HdlTickScale';
    tickScale.Entries=set(this,'HdlTickScale').';
    tickScale.Mode=1;
    tickScale.Tunable=0;
    tickScale.RowSpan=[4,4];
    tickScale.ColSpan=[2,2];
    tickScale.Alignment=5;


    tickMode.Type='combobox';
    tickMode.Tag='HdlTickMode';
    tickMode.MatlabMethod='cosimDDGSync';
    tickMode.MatlabArgs={this,'%dialog','%tag'};
    tickMode.ObjectProperty='HdlTickMode';
    tickMode.Entries=set(this,'HdlTickMode').';
    tickMode.Mode=1;
    tickMode.Tunable=0;
    tickMode.RowSpan=[4,4];
    tickMode.ColSpan=[3,3];
    tickMode.Alignment=5;






    timingGroup.Type='group';
    timingGroup.Name='Timescale';
    timingGroup.Tag='timingGroup';
    timingGroup.Items={...
    fillerRow1Label,...
    oneSecLabel,timingScaleFactor,timingMode,modLabel,...
    fillerRow1Label,...
    tickText,tickScale,tickMode,...
fillerRow1Label...
    };
    timingGroup.LayoutGrid=[5,4];






    paramGroup.Type='group';
    paramGroup.Name='Parameters';
    paramGroup.Tag='paramGroup';
    paramGroup.Items={...
    fillerRow1Label,...
    fnText,...
    fnEdit,...
    fillerRow1Label,...
    inportText,inportEdit,...
    fillerRow1Label,...
timingGroup...
    };















    mainPanel.Type='panel';
    mainPanel.Tag='mainPanel';
    mainPanel.Items={descrGroup,paramGroup};










    title=this.Block.Name;

    title(find(double(title)==10))=' ';
    dlgStruct.DialogTitle=['Block Parameters: ',title];
    dlgStruct.HelpMethod='eval';
    dlgStruct.HelpArgs={this.Block.MaskHelp};
    dlgStruct.Items={mainPanel};
    dlgStruct.DialogTag=this.Block.Name;
    dlgStruct.PreApplyMethod='preApply';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};
    dlgStruct.SmartApply=0;
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
    dlgStruct.DefaultOk=false;

    if any(strcmp(this.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=1;
    end
