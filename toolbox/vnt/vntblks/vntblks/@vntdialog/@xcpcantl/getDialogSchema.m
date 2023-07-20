function dlgStruct=getDialogSchema(obj,~)













    [allDevices,objConstructors]=canslshared.internal.parseHardwareInfo('CAN');
    allDevices=[{'Select a device'},allDevices];
    objConstructors=[{'Select a constructor'},objConstructors];
    vntslshared.internal.setupDevice(obj,allDevices,objConstructors);
    obj.Device=obj.DeviceMenu;



    rowSpan=[1,1];
    colSpan=[1,5];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    rowInDialog=1;
    widgetTags=vntslshared.internal.getStrings('alltags');


    colSpan=[1,2];
    DeviceMenuText=tamslgate('privateslwidgettext','Device:',...
    widgetTags.DeviceMenuText,[rowInDialog,rowInDialog],colSpan);
    DeviceMenuText.Alignment=5;
    colSpan=[3,5];
    DeviceMenuField=tamslgate('privateslwidgetcombo',...
    'Device:',widgetTags.DeviceMenu,...
    allDevices,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    DeviceMenuField.Mode=true;
    DeviceMenuField.DialogRefresh=true;
    DeviceMenuField.HideName=true;


    rowInDialog=rowInDialog+1;
    colSpan=[1,2];
    BusSpeedText=tamslgate('privateslwidgettext','Bus speed:',...
    widgetTags.BusSpeedStrText,[rowInDialog,rowInDialog],colSpan);
    BusSpeedText.Alignment=5;
    colSpan=[3,5];
    BusSpeedField=tamslgate('privateslwidgetedit','Bus speed:',widgetTags.BusSpeedStr,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    BusSpeedField.HideName=true;
    if strcmpi(obj.DeviceMenu,'Select a device')
        BusSpeedField.Enabled=false;
    else
        BusSpeedField.Enabled=true;
    end


    rowInDialog=rowInDialog+1;
    colSpan=[1,2];
    SampleTimeText=tamslgate('privateslwidgettext','Sample time:',...
    widgetTags.SampleTimeText,[rowInDialog,rowInDialog],colSpan);
    SampleTimeText.Alignment=5;

    colSpan=[3,5];
    SampleTimeField=tamslgate('privateslwidgetedit','Sample time:',widgetTags.SampleTime,...
    [rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    SampleTimeField.HideName=true;


    items={DeviceMenuField,DeviceMenuText,...
    BusSpeedField,BusSpeedText,...
    SampleTimeField,SampleTimeText};

    paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
    items,[2,2],[1,5],[rowInDialog+1,3]);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'vntslshared.internal.preApplyCallback','closeCallback');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if(isLibrary&&isLocked)||any(strcmp(obj.Root.SimulationStatus,{'running','paused','external'}))
        dlgStruct.DisableDialog=true;
    end

    obj.IsDifferentDevice=false;
end
