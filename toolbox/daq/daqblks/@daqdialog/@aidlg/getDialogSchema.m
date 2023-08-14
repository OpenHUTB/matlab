function dlgStruct=getDialogSchema(obj,~)














    obj.subSystemType='AnalogInput';
    measurementType={'Voltage'};
    checkClock=1;
    allDeviceList=daqblks.internal.findDevice(obj.subSystemType,measurementType,checkClock);
    deviceDisplayList=daqblks.internal.getDeviceDisplayList(allDeviceList);



    existDAQObject=daqblks.internal.setupDevice(obj,allDeviceList,deviceDisplayList);

    channelDataGenereatedFromObject=true;
    try

        localAddChannels(obj,allDeviceList,measurementType,existDAQObject);
    catch e
        uiwait(warndlg(e.message,message('daq:daqblks:deviceNotUsableTitle').getString));
        channelDataGenereatedFromObject=false;
        [obj.Channels,numChannelsSelected]=daqblks.internal.populateTableWithoutObject(obj.channelInfoList,obj.subSystemType);
        obj.NChannelsSelected=num2str(numChannelsSelected);
    end


    rowSpan=[1,1];
    colSpan=[1,4];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateAIParamGroup(obj,deviceDisplayList,existDAQObject,channelDataGenereatedFromObject);


    daqblks.internal.updateDialogObject(obj);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'daqblks.daqcbpreapply','daqblks.daqcbclosedialog');


    dlgStruct=daqblks.internal.disableDialog(obj,dlgStruct);

    dlgStruct.OpenCallback=@daqblks.internal.onMaskOpen;
    obj.EnableApplyButton=obj.IsDifferentDevice;


    obj.IsDifferentDevice=false;


    function parameterPane=localCreateAIParamGroup(obj,devices,existDAQObject,channelDataGenereatedFromObject)


        AIWidgetTags=daqblks.internal.getString('aitags');

        rowInDialog=1;
        colSpan=[1,3];
        DaqDeviceMenu=tamslgate('privateslwidgetcombo',sprintf('Device:'),...
        AIWidgetTags.DeviceMenu,devices,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');
        DaqDeviceMenu.Mode=true;

        rowInDialog=rowInDialog+1;

        entries=localAcqModeEntries();

        colSpan=[1,3];
        AcquisitionModeMenu=tamslgate('privateslwidgetradio',...
        sprintf('Acquisition Mode'),AIWidgetTags.AcqMode,...
        entries,[rowInDialog,rowInDialog+1],colSpan,'daqblks.daqslcallback');
        AcquisitionModeMenu.Value=str2double(obj.AcqMode);



        rowInDialog=rowInDialog+2;
        colSpan=[1,1];
        TableHeaderText=tamslgate('privateslwidgettext',sprintf(' Channels:'),...
        AIWidgetTags.TableHeaderText,...
        [rowInDialog,rowInDialog],colSpan);
        TableHeaderText.Alignment=5;


        colSpan=[2,2];
        SelectAll=tamslgate('privateslwidgetpushbutton',sprintf('Select All'),...
        AIWidgetTags.SelectAll,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');

        SelectAll.Alignment=7;


        colSpan=[3,3];
        UnselectAll=tamslgate('privateslwidgetpushbutton',sprintf('Unselect All'),...
        AIWidgetTags.UnselectAll,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        ChannelTable=localCreateTable(obj,existDAQObject,AIWidgetTags);
        ChannelTable.RowSpan=[rowInDialog,rowInDialog];


        rowInDialog=rowInDialog+2;
        colSpan=[1,3];
        entries={'1 for all channels','1 per channel'};
        NPortsMenu=tamslgate('privateslwidgetcombo',sprintf('Number of ports:'),...
        AIWidgetTags.NPorts,entries,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,4];
        SampleRateField=tamslgate('privateslwidgetedit',sprintf('Input sample rate (samples/second):'),...
        AIWidgetTags.SampleRate,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');

        if strcmpi(obj.Device,'(none)')||isempty(obj.DAQObject)
            obj.SampleRate='0';
            obj.ActualRate='0';
            obj.ScansPerTrigger='0';
        else
            if~isempty(obj.DAQObject.RateLimit)



                if obj.DAQObject.RateLimit(1)==obj.DAQObject.RateLimit(2)
                    SampleRateField.Enabled=false;
                end
            else


                rateLimits=daqblks.internal.getDeviceSampleRateLimit(obj.DAQObject.Vendor.ID,obj.channelInfoList,obj.subSystemType);
                if rateLimits(1)==rateLimits(2)
                    SampleRateField.Enabled=false;
                end
            end
        end




        rowInDialog=rowInDialog+1;
        [SampleRateMsg,LinkMessage]=daqblks.internal.createRateMessage(obj,...
        [rowInDialog,rowInDialog],AIWidgetTags,...
        str2double(obj.SampleRate),str2double(obj.ActualRate));
        SampleRateMsg.ColSpan=[1,2];
        LinkMessage.ColSpan=[2,2];



        rowInDialog=rowInDialog+1;
        colSpan=[1,4];
        ScansPerTriggerField=tamslgate('privateslwidgetedit',sprintf('Block size:'),...
        AIWidgetTags.ScansPerTrigger,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        OutputTimeStampField=tamslgate('privateslwidgetcheckbox',sprintf('Output relative timestamps'),...
        AIWidgetTags.OutputTimestamp,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');
        OutputTimeStampField.Mode=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        OutputTriggertimeField=tamslgate('privateslwidgetcheckbox',sprintf('Output trigger time'),...
        AIWidgetTags.OutputTriggertime,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');
        OutputTriggertimeField.Mode=true;
        OutputTriggertimeField.Visible=false;



        if strcmp(obj.Device,'(none)')||isempty(obj.DAQObject)||...
            ~channelDataGenereatedFromObject






            SampleRateField.Enabled=false;
            SampleRateMsg.Visible=false;
            NPortsMenu.Enabled=false;
            SelectAll.Enabled=false;
            UnselectAll.Enabled=false;
            ChannelTable.Enabled=false;
            OutputTimeStampField.Enabled=false;
            ScansPerTriggerField.Enabled=false;
            AcquisitionModeMenu.Enabled=false;
        end



        items={DaqDeviceMenu,AcquisitionModeMenu,TableHeaderText,SelectAll,UnselectAll,...
        ChannelTable,NPortsMenu,SampleRateField,SampleRateMsg,LinkMessage,...
        OutputTimeStampField,ScansPerTriggerField};
        colSpan=[1,4];
        parameterPane=tamslgate('privateslwidgetgroup','Parameters',AIWidgetTags.ParameterPane,...
        items,[2,2],colSpan,[rowInDialog,4]);

        parameterPane.RowStretch=zeros(1,rowInDialog);

        parameterPane.ColStretch=[0,1,0,0];


        function ChannelTable=localCreateTable(obj,existDAQObject,AIWidgetTags)

            channelInfoList=obj.channelInfoList;



            localGenerateTableInfo(obj,existDAQObject);
            data='';

            ChannelTable=tamslgate('privateslwidgetbasestruct','table','',AIWidgetTags.ChannelTable);

            if~strcmp(obj.Channels,'')
                for nRow=1:length(obj.ChannelsSchema)
                    source=obj.ChannelsSchema(nRow);

                    RowCheckbox=tamslgate('privateslwidgetbasestruct','checkbox',...
                    '','CheckBoxValue');
                    RowCheckbox.Mode=true;
                    RowCheckbox.ObjectProperty='CheckBoxValue';
                    RowCheckbox.Source=source;
                    data{nRow,1}=RowCheckbox;


                    HWChannelIDField=tamslgate('privateslwidgetbasestruct','edit',...
                    sprintf('ChannelID%d',nRow),'HWChannelID');
                    HWChannelIDField.Mode=true;
                    HWChannelIDField.ObjectProperty='HWChannelID';
                    HWChannelIDField.Source=source;
                    data{nRow,2}=HWChannelIDField;


                    NameField=tamslgate('privateslwidgetbasestruct','edit',...
                    sprintf('ChannelName%d',nRow),'Name');
                    NameField.Type='edit';
                    NameField.Mode=true;
                    NameField.ObjectProperty='Name';
                    NameField.Source=source;
                    data{nRow,3}=NameField;


                    ModuleField=tamslgate('privateslwidgetbasestruct','edit',...
                    sprintf('ModuleName%d',nRow),'ModuleName');
                    ModuleField.Mode=true;
                    ModuleField.ObjectProperty='Module';
                    ModuleField.Source=source;
                    data{nRow,4}=ModuleField;

                    channelName=source.HWChannelID;
                    module=source.Module;
                    channelIdx=strcmp({channelInfoList(:).channelName},channelName)&...
                    strcmp({channelInfoList(:).module},module);
                    channelInfo=channelInfoList(channelIdx);

                    MeasurementTypeField=tamslgate('privateslwidgetbasestruct','combobox',...
                    sprintf('MeasurementType%d',nRow),'MeasurementType');
                    MeasurementTypeField.Mode=true;
                    MeasurementTypeField.Entries=channelInfo.measurementTypesAvailable;
                    MeasurementTypeField.Values=1:length(MeasurementTypeField.Entries);
                    MeasurementTypeField.Value=eval(source.MeasurementType);
                    data{nRow,5}=MeasurementTypeField;


                    TermConfigField=tamslgate('privateslwidgetbasestruct','combobox',...
                    sprintf('TermConfig%d',nRow),'TermConfig');
                    TermConfigField.Mode=true;
                    TermConfigField.Entries=channelInfo.terminalConfigsAvailable;
                    TermConfigField.Values=1:length(TermConfigField.Entries);
                    TermConfigField.Value=eval(source.TerminalConfiguration);
                    data{nRow,6}=TermConfigField;


                    InputRangeField=tamslgate('privateslwidgetbasestruct','combobox',...
                    sprintf('ChannelRange%d',nRow),'InputRange');
                    InputRangeField.Mode=true;

                    rangeStringCell=arrayfun(@(x)char(x),channelInfo.rangesAvailable,'UniformOutput',false);
                    InputRangeField.Entries=rangeStringCell;
                    InputRangeField.Values=1:length(InputRangeField.Entries);
                    InputRangeField.Value=eval(source.InputRange);
                    data{nRow,7}=InputRangeField;


                    CouplingField=tamslgate('privateslwidgetbasestruct','combobox',...
                    sprintf('Coupling%d',nRow),'Coupling');
                    CouplingField.Mode=true;
                    CouplingField.Entries=channelInfo.couplingsAvailable;
                    CouplingField.Values=1:length(CouplingField.Entries);
                    CouplingField.Value=eval(source.CouplingType);
                    data{nRow,8}=CouplingField;
                end
                ChannelTable.Size=[length(obj.ChannelsSchema),8];
            else

                ChannelTable.Size=[0,8];
            end
            ChannelTable.Grid=true;
            ChannelTable.Editable=true;
            ChannelTable.RowSpan=[4,4];
            ChannelTable.ColSpan=[1,3];
            ChannelTable.ColHeader={sprintf(' '),sprintf('Channel\nID'),...
            sprintf('Name'),sprintf('Module'),sprintf('Measurement\nType'),...
            sprintf('Terminal\nConfig'),sprintf('Input\nRange'),sprintf('Coupling')};

            ChannelTable.ColumnCharacterWidth=[2,6,8,8,8,11,11,7];
            ChannelTable.ColumnHeaderHeight=2;

            ChannelTable.HeaderVisibility=[0,1];
            ChannelTable.RowHeaderWidth=0;

            ChannelTable.ReadOnlyColumns=[1,3];


            ChannelTable.MinimumSize=[400,110];
            ChannelTable.MaximumSize=[1500,880];

            ChannelTable.ValueChangedCallback=@localCellValueChanged;
            ChannelTable.Data=data;


            function localCellValueChanged(dialog,row,column,value)

                obj=dialog.getDialogSource;



                rowIndex=row+1;
                colIndex=column+1;


                AIWidgetTags=daqblks.internal.getString('aisstags');


                errorStrings=daqblks.internal.getString('ErrorStrings');

                if~isvalid(obj.DAQObject)

                    errmsg=sprintf(errorStrings.ObjectDeleted,obj.Block.getFullName);
                    uiwait(errordlg(errmsg));
                    return;
                end

                [checkBoxSelection,hwID,name,module,measurementTypeSelections,...
                rangeSelections,termConfigSelections,couplingSelections]=...
                daqblks.internal.parseAndUpdateTable(obj.Channels,obj.subSystemType);
                channelInfoList=obj.channelInfoList;

                currentRowInfo=obj.ChannelsSchema(rowIndex);
                currentChannelID=currentRowInfo.HWChannelID;
                currentDeviceID=currentRowInfo.Module;
                currentChannelIdx=daqblks.internal.locateChannelIndexInSession(obj.DAQObject,currentChannelID,currentDeviceID);
                currentChannelInfo=daqblks.internal.locateChannelInfo(channelInfoList,currentChannelID,currentDeviceID);
                vendorID=obj.DAQObject.Vendor.ID;

                errmsg='';
                switch(column)
                case 0

                    if(checkBoxSelection(rowIndex)==value)
                        return;
                    end
                    rateChanged=false;

                    if(value==0)
                        try



                            if~isempty(currentChannelIdx)
                                obj.DAQObject.removeChannel(currentChannelIdx);
                            end

                            obj.NChannelsSelected=num2str(str2double(obj.NChannelsSelected)-1);

                            rateChanged=daqblks.internal.updateSampleRate(obj);
                        catch exception
                            errmsg=exception.message;
                        end
                    else
                        oldCheckBoxSelection=checkBoxSelection;
                        try
                            checkBoxSelection(rowIndex)=value;



                            delete(obj.DAQObject);
                            obj.DAQObject=daq.createSession(vendorID);


                            daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,channelInfoList,...
                            checkBoxSelection,hwID,module,measurementTypeSelections,...
                            rangeSelections,termConfigSelections,couplingSelections);

                            obj.NChannelsSelected=num2str(str2double(obj.NChannelsSelected)+1);
                            rateChanged=daqblks.internal.updateSampleRate(obj);
                        catch exception




                            if any(oldCheckBoxSelection~=0)
                                delete(obj.DAQObject);
                                obj.DAQObject=daq.createSession(vendorID);
                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,channelInfoList,...
                                oldCheckBoxSelection,hwID,module,measurementTypeSelections,...
                                rangeSelections,termConfigSelections,couplingSelections);
                            end
                            errmsg=exception.message;
                        end
                    end

                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,num2str(checkBoxSelection(rowIndex)));
                        return;
                    end
                    currentRowInfo.CheckBoxValue=value;
                    if rateChanged
                        dialog.refresh();
                    end
                case 1
                case 2

                    if strcmp(name{rowIndex},value)
                        return;
                    end
                    if(~isempty(strfind(value,'$'))||~isempty(strfind(value,'#')))

                        tamslgate('privatesldialogbox',dialog,...
                        errorStrings.AnalogChannelName,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,name{rowIndex});
                        return;
                    end
                    currentRowInfo.Name=value;
                case 3
                case 4

                    if(measurementTypeSelections(rowIndex)==value)
                        return;
                    end
                    try


                        if(checkBoxSelection(rowIndex))
                            obj.DAQObject.Channels(currentChannelIdx).MeasurementType=currentChannelInfo.measurementTypesAvailable{value};
                        end
                    catch exception
                        errmsg=exception.message;
                    end
                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);
                        dispString=currentChannelInfo.measurementTypesAvailable{measurementTypeSelections(rowIndex)};

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.MeasurementType=num2str(value);
                case 5

                    if(termConfigSelections(rowIndex)==value)
                        return;
                    end
                    try


                        if(checkBoxSelection(rowIndex))
                            obj.DAQObject.Channels(currentChannelIdx).TerminalConfig=currentChannelInfo.terminalConfigsAvailable{value};
                        end
                    catch exception
                        errmsg=exception.message;
                    end
                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);
                        dispString=currentChannelInfo.terminalConfigsAvailable{termConfigSelections(rowIndex)};

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.TerminalConfiguration=num2str(value);


                    colIndex=colIndex+1;
                case 6

                    if(rangeSelections(rowIndex)==value)
                        return;
                    end
                    try


                        if(checkBoxSelection(rowIndex))
                            obj.DAQObject.Channels(currentChannelIdx).Range=currentChannelInfo.rangesAvailable(value).double;
                        end
                    catch exception
                        errmsg=exception.message;
                    end
                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);
                        dispString=currentChannelInfo.rangesAvailable(rangeSelections(rowIndex)).char;

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.InputRange=num2str(value);


                    colIndex=colIndex-1;
                case 7

                    if(couplingSelections(rowIndex)==value)
                        return;
                    end
                    try


                        if(checkBoxSelection(rowIndex))
                            obj.DAQObject.Channels(currentChannelIdx).Coupling=currentChannelInfo.couplingsAvailable{value};
                        end
                    catch exception
                        errmsg=exception.message;
                    end
                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);
                        dispString=currentChannelInfo.couplingsAvailable{couplingSelections(rowIndex)};

                        dialog.setTableItemValue(AIWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.CouplingType=num2str(value);
                end



                obj.Channels=daqblks.internal.parseAndUpdateTable(obj.Channels,rowIndex,colIndex,value);


                function localGenerateTableInfo(obj,existDAQObject)


                    if(~strcmp(obj.Channels,'')&&(~existDAQObject))
                        [checkBoxSelection,hwID,name,module,measurementTypeSelections,...
                        rangeSelections,termConfigSelections,couplingSelections]=...
                        daqblks.internal.parseAndUpdateTable(obj.Channels,obj.subSystemType);

                        for idx=1:length(hwID)
                            channelInfo={num2str(checkBoxSelection(idx));hwID{idx};name{idx};...
                            module{idx};num2str(measurementTypeSelections(idx));num2str(rangeSelections(idx));...
                            num2str(termConfigSelections(idx));num2str(couplingSelections(idx))};





                            if(idx==1)
                                obj.ChannelsSchema=daqdialog.tabledlg(channelInfo,obj.subSystemType);
                            else
                                obj.ChannelsSchema(idx)=daqdialog.tabledlg(channelInfo,obj.subSystemType);
                            end
                        end
                    end


                    function localAddChannels(obj,allDeviceList,measurementType,existDAQObject)


                        if strcmp(obj.Device,'(none)')||isempty(obj.DAQObject)
                            obj.Channels='';
                            return;
                        end
                        checkClockSupport=1;

                        obj.channelInfoList=daqblks.internal.getChannelInfo(allDeviceList,obj.Device,obj.subSystemType,checkClockSupport,measurementType);


                        if~existDAQObject
                            if obj.IsDifferentDevice

                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,obj.channelInfoList);


                                tableData=daqblks.internal.populateTable(obj.DAQObject,obj.channelInfoList,obj.subSystemType);
                                obj.NChannelsSelected=num2str(length(obj.channelInfoList));
                                obj.Channels=tableData;
                            else


                                [checkBoxSelections,hwIDs,~,modules,measurementTypeSelections,...
                                inputRangeSelections,termConfigSelections,couplingSelections]=...
                                daqblks.internal.parseAndUpdateTable(obj.Channels,obj.subSystemType);
                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,obj.channelInfoList,...
                                checkBoxSelections,hwIDs,modules,measurementTypeSelections,...
                                inputRangeSelections,termConfigSelections,couplingSelections);
                            end
                            daqblks.internal.updateSampleRate(obj);
                        end


                        function entries=localAcqModeEntries()


                            userMsgStrings=daqblks.internal.getString('UserMsgStrings');



                            AsyncStr=sprintf(userMsgStrings.AIAsynchronousDescription);
                            SyncStr=sprintf(userMsgStrings.AISynchronousDescription);
                            entries={AsyncStr,SyncStr};

