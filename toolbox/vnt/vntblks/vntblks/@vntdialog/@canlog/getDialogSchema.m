function dlgStruct=getDialogSchema(obj,~)













    [allDevices,objConstructors]=canslshared.internal.parseHardwareInfo('CAN');
    allDevices=[{'Select a device'},allDevices];
    objConstructors=[{'Select a constructor'},objConstructors];


    vntslshared.internal.setupDevice(obj,allDevices,objConstructors);
    obj.Device=obj.DeviceMenu;


    rowSpan=[1,1];
    colSpan=[1,20];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateParamGroup(obj,allDevices);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'vntslshared.internal.preApplyCallback','canslshared.internal.closeDialog');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if(isLibrary&&isLocked)||any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    end

    obj.IsDifferentDevice=false;
end

function paramPane=localCreateParamGroup(obj,allDevices)


    rowInDialog=1;


    widgetTags=vntslshared.internal.getStrings('canlog');


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
    MaxNumMessagesText=tamslgate('privateslwidgettext',widgetPrompts.MaxNumMessagesPrompt,...
    widgetTags.MaxNumMessagesText,[rowInDialog,rowInDialog],colSpan);
    MaxNumMessagesText.Alignment=5;

    colSpan=[6,20];
    MaxNumMessagesField=tamslgate('privateslwidgetedit',widgetPrompts.MaxNumMessagesPrompt,widgetTags.MaxNumMessages,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    MaxNumMessagesField.HideName=true;


    rowInDialog=rowInDialog+1;

    colSpan=[1,3];
    LogMessagesFromText=tamslgate('privateslwidgettext',widgetPrompts.LogMessagesFromPrompt,...
    widgetTags.LogMessagesFromText,[rowInDialog,rowInDialog],colSpan);
    LogMessagesFromText.Alignment=5;

    colSpan=[4,20];
    entries={'CAN Bus','Input port'};
    LogMessagesFromField=tamslgate('privateslwidgetcombo',...
    widgetPrompts.LogMessagesFromPrompt,widgetTags.LogMessagesFrom,...
    entries,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    LogMessagesFromField.Mode=true;
    LogMessagesFromField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[2,4];
    DeviceMenuText=tamslgate('privateslwidgettext',widgetPrompts.DeviceMenuPrompt,...
    widgetTags.DeviceMenuText,[rowInDialog,rowInDialog],colSpan);
    DeviceMenuText.Alignment=5;
    colSpan=[4,20];
    DeviceMenuField=tamslgate('privateslwidgetcombo',...
    widgetPrompts.DeviceMenuPrompt,widgetTags.DeviceMenu,...
    allDevices,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    DeviceMenuField.Mode=true;
    DeviceMenuField.DialogRefresh=true;
    DeviceMenuField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[2,4];
    SampleTimeText=tamslgate('privateslwidgettext',widgetPrompts.SampleTimePrompt,...
    widgetTags.SampleTimeText,[rowInDialog,rowInDialog],colSpan);
    SampleTimeText.Alignment=5;

    colSpan=[4,20];
    SampleTimeField=tamslgate('privateslwidgetedit',widgetPrompts.SampleTimePrompt,widgetTags.SampleTime,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    SampleTimeField.HideName=true;


    nestedDisableWidgets();
    function nestedDisableWidgets()


        if strcmpi(obj.LogFrom,'CAN Bus')
            SampleTimeField.Enabled=true;
            DeviceMenuField.Enabled=true;
        else
            obj.DeviceMenu='Select a device';
            obj.Device=obj.DeviceMenu;
            SampleTimeField.Enabled=false;
            DeviceMenuField.Enabled=false;
        end
    end


    items={FileNameText,FileNameField,BrowseButton,...
    VariableNameText,VariableNameField,...
    MaxNumMessagesText,MaxNumMessagesField,...
    LogMessagesFromText,LogMessagesFromField,...
    DeviceMenuField,DeviceMenuText,...
    SampleTimeField,SampleTimeText};

    paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
    items,[2,2],[1,20],[rowInDialog+1,3]);
    paramPane.RowStretch=[zeros(1,rowInDialog),1];
end
