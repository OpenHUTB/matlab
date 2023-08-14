function dlgstruct=getInstallLocationSchema(hStep,dlgstruct)





    Leader.Name=hStep.StepData.Labels.Leader;
    Leader.Type='text';
    Leader.RowSpan=[1,1];
    Leader.ColSpan=[1,4];
    Leader.Visible=false;

    Choice.Name='';
    Choice.Type='radiobutton';
    Choice.RowSpan=[2,3];
    Choice.ColSpan=[1,4];
    Choice.Tag=[hStep.ID,'_Step_Choice'];
    Choice.MatlabMethod='dialogCallback';
    Choice.MatlabArgs={hStep,'Choice','%tag','%value'};
    Choice.Value=hStep.StepData.Choice;
    Choice.Entries={hStep.StepData.Labels.Internet,hStep.StepData.Labels.Download,hStep.StepData.Labels.Folder,hStep.StepData.Labels.Uninstall};
    hStep.StepData.ChoiceIndex=struct('Choice_Internet',0,'Choice_Download',1,'Choice_Folder',2,'Choice_Uninstall',3);
    Choice.Alignment=2;
    Choice.DialogRefresh=true;
    Choice.ToolTip=hStep.StepData.ToolTip.Choice;


    Folder.Type='edit';
    Folder.Value=hStep.StepData.Folder;
    Folder.Tag=[hStep.ID,'_Step_Folder'];
    Folder.RowSpan=[4,4];
    Folder.ColSpan=[2,3];
    Folder.Visible=isequal(hStep.StepData.Choice,hStep.StepData.ChoiceIndex.Choice_Folder);
    Folder.Enabled=Folder.Visible;
    Folder.ToolTip=hStep.StepData.ToolTip.Folder;

    Browse.Name=hStep.StepData.Labels.Browse;
    Browse.Type='pushbutton';
    Browse.Tag=[hStep.ID,'_Step_Browse'];
    Browse.RowSpan=[4,4];
    Browse.ColSpan=[4,4];
    Browse.Visible=isequal(hStep.StepData.Choice,hStep.StepData.ChoiceIndex.Choice_Folder);
    Browse.Enabled=Browse.Visible;
    Browse.MatlabMethod='dialogCallback';
    Browse.MatlabArgs={hStep,'Browse','%tag','%dialog',Folder.Tag};
    Browse.DialogRefresh=true;
    Browse.ToolTip=hStep.StepData.ToolTip.Browse;

    SelectActionHelpText.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_SelectActionHelpText'));
    SelectActionHelpText.Type='text';
    SelectActionHelpText.Tag=[hStep.ID,'_Step_SelectActionHelpText'];

    SelectActionHelpPanel.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_SelectActionHelpPanel'));
    SelectActionHelpPanel.Type='togglepanel';
    SelectActionHelpPanel.Tag=[hStep.ID,'_Step_ExplanationInstallOptions'];
    SelectActionHelpPanel.RowSpan=[5,5];
    SelectActionHelpPanel.ColSpan=[1,5];
    SelectActionHelpPanel.Items={SelectActionHelpText};



    HardwareConfigureText.Tag=[hStep.ID,'_Step_HardwareConfigureText'];
    if hwconnectinstaller.util.isFirmwareUpdateAvailable


        HardwareConfigureText.Type='hyperlink';
        HardwareConfigureText.Name=[char(9),DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_HardwareConfigureText_ConfigRequired'))];
        HardwareConfigureText.MatlabMethod='dialogCallback';
        HardwareConfigureText.MatlabArgs={hStep,'HardwareConfigure'};
    else


        HardwareConfigureText.Type='text';
        HardwareConfigureText.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_HardwareConfigureText_NoConfigRequired'));
    end

    HardwareConfigurePanel.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_HardwareConfigurePanel'));
    HardwareConfigurePanel.Type='togglepanel';
    HardwareConfigurePanel.Tag=[hStep.ID,'_Step_ExplanationHwSetup'];
    HardwareConfigurePanel.RowSpan=[6,6];
    HardwareConfigurePanel.ColSpan=[1,5];
    HardwareConfigurePanel.Items={HardwareConfigureText};

    dlgstruct.Items{3}.Visible=false;

    dlgstruct.Items{1}=Leader;
    dlgstruct.Items{end+1}=Choice;
    dlgstruct.Items{end+1}=Folder;
    dlgstruct.Items{end+1}=Browse;
    dlgstruct.Items{end+1}=SelectActionHelpPanel;
    dlgstruct.Items{end+1}=HardwareConfigurePanel;
end
