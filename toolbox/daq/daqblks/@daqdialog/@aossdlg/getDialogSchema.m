function dlgStruct=getDialogSchema(obj,~)














    obj.subSystemType='AnalogOutput';
    measurementType={'Voltage'};
    checkClock=-1;
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
    colSpan=[1,3];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateAOParamGroup(obj,deviceDisplayList,existDAQObject,channelDataGenereatedFromObject);


    daqblks.internal.updateDialogObject(obj);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'daqblks.daqcbpreapply','daqblks.daqcbclosedialog');


    dlgStruct=daqblks.internal.disableDialog(obj,dlgStruct);

    dlgStruct.OpenCallback=@daqblks.internal.onMaskOpen;
    obj.EnableApplyButton=obj.IsDifferentDevice;


    obj.IsDifferentDevice=false;

    function parameterPane=localCreateAOParamGroup(obj,devices,existDAQObject,channelDataGenereatedFromObject)

        rowInDialog=1;


        AOWidgetTags=daqblks.internal.getString('aosstags');


        colSpan=[1,3];
        DaqDeviceMenu=tamslgate('privateslwidgetcombo',sprintf('Device:'),...
        AOWidgetTags.DeviceMenu,devices,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');
        DaqDeviceMenu.Mode=true;



        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        TableHeaderText=tamslgate('privateslwidgettext',sprintf(' Channels:'),...
        AOWidgetTags.TableHeaderText,...
        [rowInDialog,rowInDialog],colSpan);
        TableHeaderText.Alignment=8;


        colSpan=[2,2];
        SelectAll=tamslgate('privateslwidgetpushbutton',sprintf('Select All'),...
        AOWidgetTags.SelectAll,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');

        SelectAll.Alignment=7;


        colSpan=[3,3];
        UnselectAll=tamslgate('privateslwidgetpushbutton',sprintf('Unselect All'),...
        AOWidgetTags.UnselectAll,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        ChannelTable=localCreateTable(obj,existDAQObject,AOWidgetTags);


        rowInDialog=rowInDialog+2;
        colSpan=[1,3];
        entries={'1 for all channels','1 per channel'};
        NPortsMenu=tamslgate('privateslwidgetcombo',sprintf('Number of ports:'),...
        AOWidgetTags.NPorts,entries,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        BlockSampleTimeField=tamslgate('privateslwidgetedit',sprintf('Sample time: '),...
        AOWidgetTags.BlockSampleTime,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');


        if strcmp(obj.Device,'(none)')||isempty(obj.DAQObject)||...
            ~channelDataGenereatedFromObject
            NPortsMenu.Enabled=false;
            SelectAll.Enabled=false;
            UnselectAll.Enabled=false;
            ChannelTable.Enabled=false;
            BlockSampleTimeField.Enabled=false;
        end


        items={DaqDeviceMenu,TableHeaderText,SelectAll,UnselectAll,ChannelTable,NPortsMenu,BlockSampleTimeField};
        colSpan=[1,3];
        parameterPane=tamslgate('privateslwidgetgroup','Parameters',AOWidgetTags.ParameterPane,...
        items,[2,2],colSpan,[rowInDialog,3]);
        parameterPane.RowStretch=zeros(1,rowInDialog);

        parameterPane.ColStretch=[0,1,0];


        function ChannelTable=localCreateTable(obj,existDAQObject,AOWidgetTags)

            channelInfoList=obj.channelInfoList;



            localGenerateTableInfo(obj,existDAQObject);
            data='';

            ChannelTable=tamslgate('privateslwidgetbasestruct','table','',AOWidgetTags.ChannelTable);

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


                    OutputRangeField=tamslgate('privateslwidgetbasestruct','combobox',...
                    sprintf('ChannelRange%d',nRow),'OutputRange');
                    OutputRangeField.Mode=true;

                    rangeStringCell=arrayfun(@(x)char(x),channelInfo.rangesAvailable,'UniformOutput',false);
                    OutputRangeField.Entries=rangeStringCell;
                    OutputRangeField.Values=1:length(OutputRangeField.Entries);
                    OutputRangeField.Value=eval(source.OutputRange);
                    data{nRow,6}=OutputRangeField;
                end
                ChannelTable.Size=[length(obj.ChannelsSchema),6];
            else

                ChannelTable.Size=[0,6];
            end
            ChannelTable.Grid=true;
            ChannelTable.Editable=true;
            ChannelTable.RowSpan=[4,4];
            ChannelTable.ColSpan=[1,3];
            ChannelTable.ColHeader={sprintf(' '),sprintf('Channel\nID'),...
            sprintf('Name'),sprintf('Module'),sprintf('Measurement\nType'),...
            sprintf('Output\nRange')};

            ChannelTable.ColumnCharacterWidth=[2,6,8,8,8,11];
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


                AOWidgetTags=daqblks.internal.getString('aosstags');


                errorStrings=daqblks.internal.getString('ErrorStrings');

                if~isvalid(obj.DAQObject)

                    errmsg=sprintf(errorStrings.ObjectDeleted,obj.Block.getFullName);
                    uiwait(errordlg(errmsg));
                    return;
                end


                [checkBoxSelection,hwID,name,module,measurementTypeSelections,...
                rangeSelections]=...
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

                    if(value==0)
                        try



                            if~isempty(currentChannelIdx)
                                obj.DAQObject.removeChannel(currentChannelIdx);
                            end

                            obj.NChannelsSelected=num2str(str2double(obj.NChannelsSelected)-1);
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
                            rangeSelections);

                            obj.NChannelsSelected=num2str(str2double(obj.NChannelsSelected)+1);
                        catch exception




                            if any(oldCheckBoxSelection~=0)
                                delete(obj.DAQObject);
                                obj.DAQObject=daq.createSession(vendorID);
                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,channelInfoList,...
                                oldCheckBoxSelection,hwID,module,measurementTypeSelections,...
                                rangeSelections);
                            end
                            errmsg=exception.message;
                        end
                    end

                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(AOWidgetTags.ChannelTable,row,column,num2str(checkBoxSelection(rowIndex)));
                        return;
                    end
                    currentRowInfo.CheckBoxValue=value;
                    value=num2str(value);
                case 1
                case 2

                    if strcmp(name{rowIndex},value)
                        return;
                    end
                    if(~isempty(strfind(value,'$'))||~isempty(strfind(value,'#')))

                        tamslgate('privatesldialogbox',dialog,...
                        errorStrings.AnalogChannelName,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(AOWidgetTags.ChannelTable,row,column,name{rowIndex});
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

                        dialog.setTableItemValue(AOWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.MeasurementType=num2str(value);
                case 5

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

                        dialog.setTableItemValue(AOWidgetTags.ChannelTable,row,column,dispString);
                        return;
                    end
                    currentRowInfo.OutputRange=num2str(value);
                end


                obj.Channels=daqblks.internal.parseAndUpdateTable(obj.Channels,rowIndex,colIndex,value);

                function localGenerateTableInfo(obj,existDAQObject)

                    if(~strcmp(obj.Channels,'')&&(~existDAQObject))
                        [checkBoxSelection,hwID,name,module,measurementTypeSelections,...
                        rangeSelections]=...
                        daqblks.internal.parseAndUpdateTable(obj.Channels,obj.subSystemType);

                        for idx=1:length(hwID)
                            channelInfo={num2str(checkBoxSelection(idx));hwID{idx};name{idx};...
                            module{idx};num2str(measurementTypeSelections(idx));...
                            num2str(rangeSelections(idx))};





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
                        checkClockSupport=-1;

                        obj.channelInfoList=daqblks.internal.getChannelInfo(allDeviceList,obj.Device,obj.subSystemType,checkClockSupport,measurementType);


                        if~existDAQObject
                            if obj.IsDifferentDevice

                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,obj.channelInfoList);


                                tableData=daqblks.internal.populateTable(obj.DAQObject,obj.channelInfoList,obj.subSystemType);
                                obj.NChannelsSelected=num2str(length(obj.channelInfoList));
                                obj.Channels=tableData;
                            else


                                [checkBoxSelections,hwIDs,~,modules,measurementTypeSelections,...
                                rangeSelections]=...
                                daqblks.internal.parseAndUpdateTable(obj.Channels,obj.subSystemType);
                                daqblks.internal.addChannels(obj.DAQObject,obj.subSystemType,obj.channelInfoList,...
                                checkBoxSelections,hwIDs,modules,measurementTypeSelections,...
                                rangeSelections);
                            end
                        end
