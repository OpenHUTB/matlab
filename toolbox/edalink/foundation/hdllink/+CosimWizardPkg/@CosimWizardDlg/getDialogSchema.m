function dlgStruct=getDialogSchema(this,~)



    h=getStepHandle(this);
    if(this.NextStepID~=this.StepID)
        EnterStep(h);
    end
    this.StepID=this.NextStepID;

    Description=getDescription(h);

    WidgetGroup=getWidgetGroup(h);
    this.WidgetStackItems{this.StepID}=WidgetGroup;

    for m=1:numel(this.WidgetStackItems)

        this.WidgetStackItems{m}.Visible=(m==this.StepID);
    end

    switch(this.UserData.Workflow)
    case{'Simulink','MATLAB System Object'}
        WorkflowSteps={'Cosimulation Type     ',...
        'HDL Files             ',...
        'HDL Compilation       ',...
        'Simulation Options    ',...
        'Input/Output Ports    ',...
        'Output Port Details   ',...
        'Clock/Reset Details   ',...
        'Start Time Alignment  '};
        if strcmpi(this.UserData.Workflow,'Simulink')
            WorkflowSteps{end+1}='Block Generation      ';
        else
            WorkflowSteps{end+1}='System Obj. Generation';
        end

        switch this.StepID
        case 1
            Buttons={'Help','Cancel','Next'};
        case{2,3,4,5,6,7,8}
            Buttons={'Help','Cancel','Back','Next'};
        otherwise
            Buttons={'Help','Cancel','Back','Finish'};
        end
    otherwise
        WorkflowSteps={'Cosimulation Type     ',...
        'HDL Files             ',...
        'HDL Compilation       ',...
        'HDL Modules           ',...
        'Callback Schedule     ',...
        'Script Generation     '};
        switch this.StepID
        case 1
            Buttons={'Help','Cancel','Next'};
        case{2,3,4,10}
            Buttons={'Help','Cancel','Back','Next'};
        otherwise
            Buttons={'Help','Cancel','Back','Finish'};
        end
    end

    MaximumWidth=500;


    row=numel(WorkflowSteps);
    NavigatorItems=cell(1,row*2);

    for m=1:row

        Status.Type='text';
        if(m==this.UserData.CurrentStep)
            Status.Name='->';
        else
            Status.Name='';
        end
        Status.RowSpan=[m,m];
        Status.ColSpan=[1,1];
        Status.Tag=sprintf('edaStep%d',m);


        Step.Type='text';
        Step.Name=WorkflowSteps{m};
        Step.RowSpan=[m,m];
        Step.ColSpan=[2,5];


        NavigatorItems{m}=Status;
        NavigatorItems{row+m}=Step;
    end

    Navigator.Name='Steps';
    Navigator.Type='group';
    Navigator.Tag='edaNavigator';
    Navigator.Items=NavigatorItems;
    Navigator.RowSpan=[1,3];
    Navigator.ColSpan=[1,1];
    Navigator.LayoutGrid=[9,5];

    Text.Type='text';
    Text.Tag='edaText';
    Text.Name=Description;
    Text.MaximumSize=[MaximumWidth*2,200];
    Text.MinimumSize=[MaximumWidth,50];
    Text.Visible=true;
    Text.RowSpan=[1,1];
    Text.ColSpan=[1,1];
    Text.Mode=1;
    Text.WordWrap=true;

    TextGroup.Type='group';
    TextGroup.Tag='edaTextGroup';
    TextGroup.Name='Actions';
    TextGroup.Visible=true;
    TextGroup.RowSpan=[1,1];
    TextGroup.ColSpan=[2,10];
    TextGroup.Items={Text};

    Status.Type='textbrowser';
    Status.Tag='edaStatus';
    Status.Name='';
    Status.MaximumSize=[MaximumWidth*10,10000];
    Status.MinimumSize=[MaximumWidth,50];
    Status.RowSpan=[1,1];
    Status.ColSpan=[1,1];
    Status.Visible=true;
    Status.Enabled=true;
    Status.HideName=false;
    Status.Mode=1;
    Status.Text=this.Status;
    StatusGroup.Type='group';
    StatusGroup.Tag='edaStatusGroup';
    StatusGroup.Name='Status';
    StatusGroup.RowSpan=[6,7];
    StatusGroup.ColSpan=[2,10];
    StatusGroup.Items={Status};


    buttonWidgets=l_getButtonSet(Buttons);
    buttonWidgets.RowSpan=[8,8];
    buttonWidgets.ColSpan=[2,10];
    buttonWidgets.Enabled=this.EnableButtons;


    dlgStruct.DialogTitle='Cosimulation Wizard';
    dlgStruct.Items={Navigator,TextGroup,this.WidgetStackItems{:},StatusGroup,buttonWidgets};%#ok<CCAT>
    dlgStruct.LayoutGrid=[8,10];
    dlgStruct.RowStretch=[0,1,1,1,1,1,1,0];
    dlgStruct.ColStretch=[0,1,1,1,1,1,1,1,1,1];
    dlgStruct.ShowGrid=false;

    dlgStruct.StandaloneButtonSet={''};


    dlgStruct.DialogTag=class(this);
    dlgStruct.CloseMethod='onCancel';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    switch(this.UserData.Workflow)
    case 'Simulink'
        dlgStruct.DisplayIcon=...
        'toolbox\shared\dastudio\resources\SimulinkModelIcon.png';
    otherwise
        dlgStruct.DisplayIcon=...
        'toolbox\shared\dastudio\resources\MatlabIcon.png';
    end

end

function button=l_getPushButton(Name,Tag,ObjectMethod,Position)
    button.Name=Name;
    button.Tag=Tag;
    button.WidgetId=Name;
    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=[1,1];
    button.ColSpan=[Position,Position];
    button.Visible=false;
end

function ButtonSet=l_getButtonSet(buttonNames)
    BtnHelp=l_getPushButton('Help','edaHelp','onHelp',1);
    BtnCancel=l_getPushButton('Cancel','edaCancel','onCancel',2);
    BtnBack=l_getPushButton('< Back','edaBack','onBack',6);
    BtnNext=l_getPushButton('Next >','edaNext','onNext',7);
    BtnFinish=l_getPushButton('Finish','edaFinish','onNext',7);

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
        case 'Finish'
            BtnFinish.Visible=true;
        end
    end

    ButtonSet.Type='panel';
    ButtonSet.Name='Buttons';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,7];
    ButtonSet.ColStretch=[1,1,1,1,1,1,1];
    ButtonSet.Items={BtnHelp,BtnCancel,BtnBack,BtnNext,BtnFinish};
end



