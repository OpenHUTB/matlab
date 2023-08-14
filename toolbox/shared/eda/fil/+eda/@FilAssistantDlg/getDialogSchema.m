function dlgStruct=getDialogSchema(this,~)





    assert(license('test','EDA_Simulator_Link')==1,...
    'EDALink:FilAssistantDlg:NoLicense',...
    'HDL Verifier license is not available.');



    switch(this.StepID)
    case 1
        Description=this.getCatalogMsgStr('Description1_Text');
        this.WidgetStackItems{1}=this.getHwOptWidgets;
    case 2
        Description=this.getCatalogMsgStr('Description2_Text');
        this.WidgetStackItems{2}=this.getSrcFileWidgets;
    case 3
        Description=this.getCatalogMsgStr('Description3_Text');
        this.WidgetStackItems{3}=this.getPortsWidgets;
    case 4
        Description=this.getCatalogMsgStr('Description4_Text');
        this.WidgetStackItems{4}=this.getOutputTypesWidgets;
    case 5
        Description=this.getCatalogMsgStr('Description5_Text');
        this.WidgetStackItems{5}=this.getBuildOptWidgets;
    end

    this.WidgetStackItems{this.StepID}.Enabled=this.EnableDialog;
    WidgetStack.Type='widgetstack';
    WidgetStack.Tag='edaWidgetStack';
    WidgetStack.ActiveWidget=this.StepID-1;
    WidgetStack.Items=this.WidgetStackItems;
    WidgetStack.RowSpan=[2,4];
    WidgetStack.ColSpan=[2,10];


    row=5;
    NavigatorItems=cell(1,row*2+2);
    for m=1:row

        Status.Type='text';
        if m==this.StepID
            Status.Name='->';
        else
            Status.Name='';
        end
        Status.RowSpan=[m,m];
        Status.ColSpan=[1,1];
        Status.Tag=sprintf('edaNavStatus%d',m);


        txtID=sprintf('Step%d_Text',m);
        Step.Type='text';
        Step.Tag=sprintf('edaNavStep%d',m);
        Step.Name=this.getCatalogMsgStr(txtID);
        Step.RowSpan=[m,m];
        Step.ColSpan=[2,5];


        NavigatorItems{m}=Status;
        NavigatorItems{row+m}=Step;
    end

    emptycell.Type='text';
    emptycell.Name='';
    emptycell.RowSpan=[6,6];
    emptycell.ColSpan=[1,1];
    NavigatorItems{11}=emptycell;

    emptycell.ColSpan=[2,5];
    NavigatorItems{12}=emptycell;


    Navigator.Name=this.getCatalogMsgStr('Steps_Text');
    Navigator.Type='group';
    Navigator.Tag='edaNavigator';
    Navigator.RowSpan=[1,2];
    Navigator.ColSpan=[1,1];
    Navigator.LayoutGrid=[row+1,5];
    Navigator.RowStretch=[0,0,0,0,0,1];
    Navigator.Items=NavigatorItems;
    Text.Type='text';
    Text.Tag='edaText';
    Text.Name=Description;
    Text.RowSpan=[1,1];
    Text.ColSpan=[1,1];
    Text.WordWrap=true;

    TextGroup.Type='group';
    TextGroup.Tag='edaTextGroup';
    TextGroup.Name=this.getCatalogMsgStr('Actions_Text');
    TextGroup.RowSpan=[1,1];
    TextGroup.ColSpan=[2,10];
    TextGroup.Items={Text};


    StatusBrowser.Type='textbrowser';
    StatusBrowser.Tag='edaStatus';
    StatusBrowser.RowSpan=[1,1];
    StatusBrowser.ColSpan=[1,1];
    StatusBrowser.Enabled=true;
    StatusBrowser.Text=this.Status;

    StatusGroup.Type='group';
    StatusGroup.Tag='edaStatusGroup';
    StatusGroup.Name=this.getCatalogMsgStr('Status_Text');
    StatusGroup.RowSpan=[5,5];
    StatusGroup.ColSpan=[2,10];
    StatusGroup.Items={StatusBrowser};


    switch this.StepID
    case 1
        Buttons={'Help','Cancel','Next'};
    case{2}
        Buttons={'Help','Cancel','Back','Next'};
    case{3}
        Buttons={'Help','Cancel','Back','Next'};
    case{4}
        Buttons={'Help','Cancel','Back','Next'};
    case{5}
        Buttons={'Help','Cancel','Back','Build'};
    end
    buttonWidgets=l_getButtonSet(Buttons);
    buttonWidgets.Enabled=this.EnableDialog;
    buttonWidgets.RowSpan=[6,6];
    buttonWidgets.ColSpan=[2,10];


    dlgStruct.DialogTitle=this.getCatalogMsgStr('Title_Dialog');
    dlgStruct.Items=[{Navigator},{TextGroup},WidgetStack,{StatusGroup},{buttonWidgets}];
    dlgStruct.LayoutGrid=[6,10];
    dlgStruct.RowStretch=[0,1,1,1,1,0];
    dlgStruct.ColStretch=[0,1,1,1,1,1,1,1,1,1];

    dlgStruct.ShowGrid=false;

    dlgStruct.StandaloneButtonSet={''};


    dlgStruct.DialogTag=class(this);

end

function button=l_getPushButton(Name,ObjectMethod,Position)
    button.Name=eda.FilAssistantDlg.getCatalogMsgStr([Name,'_Button']);
    button.Tag=['eda',Name];

    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=[1,1];
    button.ColSpan=[Position,Position];
    button.Visible=false;
end

function ButtonSet=l_getButtonSet(buttonNames)
    BtnHelp=l_getPushButton('Help','onHelp',1);
    BtnCancel=l_getPushButton('Cancel','onCancel',2);
    BtnBack=l_getPushButton('Back','onBack',6);
    BtnNext=l_getPushButton('Next','onNext',7);
    BtnBuild=l_getPushButton('Build','onNext',7);

    for m=1:numel(buttonNames)
        switch buttonNames{m}
        case 'Help'
            BtnHelp.Visible=true;
        case 'Cancel'
            BtnCancel.Visible=true;
        case 'Back'
            BtnBack.Visible=true;
        case 'Next'
            BtnNext.Visible=true;
        case 'Build'
            BtnBuild.Visible=true;
        end
    end

    ButtonSet.Type='panel';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,7];
    ButtonSet.RowStretch=1;
    ButtonSet.ColStretch=[0,0,1,1,1,0,0];
    ButtonSet.Items={BtnHelp,BtnCancel,BtnBack,BtnNext,BtnBuild};
end
