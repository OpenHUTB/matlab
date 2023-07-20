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
    ConfigNameText=tamslgate('privateslwidgettext',sprintf('Config name:'),...
    widgetTags.ConfigNameText,[rowInDialog,rowInDialog],colSpan);
    ConfigNameText.Alignment=5;

    colSpan=[3,5];
    entries=localFindValidConfigNames(obj);
    ConfigNameField=tamslgate('privateslwidgetcombo',...
    'Config name:',widgetTags.ConfigName,...
    entries,[rowInDialog,rowInDialog],colSpan,'vntslshared.internal.maskCallback');
    ConfigNameField.Mode=true;
    ConfigNameField.HideName=true;


    rowInDialog=rowInDialog+1;
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


    items={ConfigNameText,ConfigNameField,DeviceMenuField,DeviceMenuText,...
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


    function entries=localFindValidConfigNames(obj)

        entries=j1939.internal.getConfigList(bdroot);


        errorStrings=vntslshared.internal.getStrings('errorstrings');
        try
            currentSys=obj.Root.Name;
            blkDiagType=get_param(currentSys,'BlockDiagramType');
            if~strcmp(blkDiagType,'library')
                if~ismember(obj.ConfigName,entries)
                    if~obj.IsDifferentConfig

                        errMsg=sprintf(errorStrings.ConfigNotFound,obj.ConfigName);
                        uiwait(errordlg(errMsg,errorStrings.ErrorDialogTitle));
                        return;
                    end
                end

                if(numel(entries)==1)

                    if~obj.IsDifferentConfig
                        if strcmpi(obj.ConfigName,entries{1})
                            uiwait(errordlg(errorStrings.NoConfigFound,errorStrings.ErrorDialogTitle,'modal'));
                            obj.ConfigName=entries{1};
                            obj.Block.ConfigName=entries{1};
                        else
                            errMsg=sprintf(errorStrings.ConfigNotFound,obj.ConfigName);
                            uiwait(errordlg(errMsg,errorStrings.ErrorDialogTitle,'modal'));
                        end
                        return;
                    end
                end
            end
        catch err
        end