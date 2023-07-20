function dlgStruct=getDialogSchema(obj,~)













    [allDevices,objConstructors]=canslshared.internal.parseHardwareInfo('CAN FD');


    vntslshared.internal.setupDevice(obj,allDevices,objConstructors);


    rowSpan=[1,1];
    colSpan=[1,20];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateParamGroup(obj,allDevices);



    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'vntslshared.internal.preApplyCallback','canslshared.internal.closeDialog');
    dlgStruct.StandaloneButtonSet={'OK','Cancel','Help'};


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if(isLibrary&&isLocked)||any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    end


    obj.IsDifferentDevice=false;
end

function paramPane=localCreateParamGroup(obj,allDevices)


    rowInDialog=1;


    widgetTags=vntslshared.internal.getStrings('canrep');


    widgetPrompts=vntslshared.internal.getStrings('allprompts');


    colSpan=[1,3];
    FileNameText=tamslgate('privateslwidgettext',widgetPrompts.FileNamePrompt,...
    widgetTags.FileNameText,[rowInDialog,rowInDialog],colSpan);
    FileNameText.Alignment=5;

    colSpan=[3,14];
    FileNameField=tamslgate('privateslwidgetedit',widgetPrompts.FileNamePrompt,widgetTags.FullPathFileName,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    FileNameField.HideName=true;



    colSpan=[15,20];
    BrowseButton=tamslgate('privateslwidgetpushbutton',...
    widgetPrompts.BrowsePrompt,widgetTags.Browse,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    VariableNameText=tamslgate('privateslwidgettext',widgetPrompts.VariableNamePrompt,...
    widgetTags.VariableNameText,[rowInDialog,rowInDialog],colSpan);
    VariableNameText.Alignment=5;

    colSpan=[3,20];
    VariableNameField=tamslgate('privateslwidgetedit',widgetPrompts.VariableNamePrompt,widgetTags.VariableName,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    VariableNameField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[1,5];
    NoTimesReplayText=tamslgate('privateslwidgettext',widgetPrompts.NoTimesReplayPrompt,...
    widgetTags.NoTimesReplayText,[rowInDialog,rowInDialog],colSpan);
    NoTimesReplayText.Alignment=5;

    colSpan=[6,20];
    NoTimesReplayField=tamslgate('privateslwidgetedit',widgetPrompts.NoTimesReplayPrompt,widgetTags.NoTimesReplay,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    NoTimesReplayField.HideName=true;


    rowInDialog=rowInDialog+1;

    colSpan=[1,4];
    ReplayMessagesToText=tamslgate('privateslwidgettext',widgetPrompts.ReplayMessagesToPrompt,...
    widgetTags.ReplayMessagesToText,[rowInDialog,rowInDialog],colSpan);
    ReplayMessagesToText.Alignment=5;

    colSpan=[4,20];
    entries={'CAN FD Bus','Output port'};
    ReplayMessagesToField=tamslgate('privateslwidgetcombo',...
    widgetPrompts.ReplayMessagesToPrompt,widgetTags.ReplayMessagesTo,...
    entries,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    ReplayMessagesToField.Mode=true;
    ReplayMessagesToField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[2,4];
    DeviceMenuText=tamslgate('privateslwidgettext',widgetPrompts.DeviceMenuPrompt,...
    widgetTags.DeviceMenuText,[rowInDialog,rowInDialog],colSpan);
    DeviceMenuText.Alignment=5;
    colSpan=[4,20];
    DeviceMenuField=tamslgate('privateslwidgetcombo',...
    widgetPrompts.DeviceMenuPrompt,widgetTags.Device,...
    allDevices,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    DeviceMenuField.Mode=true;
    DeviceMenuField.DialogRefresh=true;
    DeviceMenuField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    SampleTimeText=tamslgate('privateslwidgettext',widgetPrompts.SampleTimePrompt,...
    widgetTags.SampleTimeText,[rowInDialog,rowInDialog],colSpan);
    SampleTimeText.Alignment=5;

    colSpan=[3,20];
    SampleTimeField=tamslgate('privateslwidgetedit',widgetPrompts.SampleTimePrompt,widgetTags.SampleTime,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    SampleTimeField.HideName=true;


    nestedDisableWidgets();
    function nestedDisableWidgets()


        if strcmpi(obj.ReplayTo,'CAN FD Bus')
            DeviceMenuField.Enabled=true;
        else
            DeviceMenuField.Enabled=false;
        end
    end


    items={FileNameText,FileNameField,BrowseButton,...
    VariableNameText,VariableNameField,...
    NoTimesReplayText,NoTimesReplayField,...
    ReplayMessagesToText,ReplayMessagesToField,...
    DeviceMenuField,DeviceMenuText,...
    SampleTimeField,SampleTimeText};

    paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
    items,[2,2],[1,20],[rowInDialog+1,3]);
    paramPane.RowStretch=[zeros(1,rowInDialog),1];
end
