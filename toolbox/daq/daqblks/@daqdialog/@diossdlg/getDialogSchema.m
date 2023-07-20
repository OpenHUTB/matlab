function dlgStruct=getDialogSchema(obj,~)














    obj.subSystemType='DigitalIO';
    if obj.IsDigitalInput
        measurementType={'InputOnly'};
    else
        measurementType={'OutputOnly'};
    end

    allDeviceList=daqblks.internal.findDevice(obj.subSystemType,measurementType,-1);
    deviceDisplayList=daqblks.internal.getDeviceDisplayList(allDeviceList);



    existDAQObject=daqblks.internal.setupDevice(obj,allDeviceList,deviceDisplayList);

    channelDataGenereatedFromObject=true;
    try

        localAddChannels(obj,allDeviceList,measurementType,existDAQObject);
    catch e
        uiwait(warndlg(e.message,message('daq:daqblks:deviceNotUsableTitle').getString));
        channelDataGenereatedFromObject=false;
        [obj.Lines,numLinesSelected]=daqblks.internal.populateTableWithoutObject(obj.channelInfoList,obj.subSystemType);
        obj.NLinesSelected=num2str(numLinesSelected);
    end


    rowSpan=[1,1];
    colSpan=[1,3];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateDigitalParamGroup(obj,deviceDisplayList,existDAQObject,channelDataGenereatedFromObject);


    daqblks.internal.updateDialogObject(obj);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'daqblks.daqcbpreapply','daqblks.daqcbclosedialog');


    dlgStruct=daqblks.internal.disableDialog(obj,dlgStruct);

    dlgStruct.OpenCallback=@daqblks.internal.onMaskOpen;
    obj.EnableApplyButton=obj.IsDifferentDevice;


    obj.IsDifferentDevice=false;


    function parameterPane=localCreateDigitalParamGroup(obj,devices,existDAQObject,channelDataGenereatedFromObject)


        rowInDialog=1;


        DIOWidgetTags=daqblks.internal.getString('diotags');


        colSpan=[1,3];
        DaqDeviceMenu=tamslgate('privateslwidgetcombo',sprintf('Device:'),...
        DIOWidgetTags.DeviceMenu,devices,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');
        DaqDeviceMenu.Mode=true;



        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        TableHeaderText=tamslgate('privateslwidgettext',sprintf(' Lines:'),...
        DIOWidgetTags.TableHeaderText,...
        [rowInDialog,rowInDialog],colSpan);
        TableHeaderText.Alignment=5;


        colSpan=[2,2];
        SelectAll=tamslgate('privateslwidgetpushbutton',sprintf('Select All'),...
        DIOWidgetTags.SelectAll,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');
        SelectAll.Alignment=7;


        colSpan=[3,3];
        UnselectAll=tamslgate('privateslwidgetpushbutton',sprintf('Unselect All'),...
        DIOWidgetTags.UnselectAll,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        LineTable=localCreateTable(obj,existDAQObject,DIOWidgetTags);


        rowInDialog=rowInDialog+2;
        colSpan=[1,3];
        entries={'1 for all lines','1 per line'};
        NPortsMenu=tamslgate('privateslwidgetcombo',sprintf('Number of ports:'),...
        DIOWidgetTags.NPorts,entries,...
        [rowInDialog,rowInDialog],colSpan,'daqblks.daqslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        BlockSampleTimeField=tamslgate('privateslwidgetedit',sprintf('Sample time:'),...
        DIOWidgetTags.BlockSampleTime,[rowInDialog,rowInDialog],...
        colSpan,'daqblks.daqslcallback');

        if obj.IsDigitalInput

            rowInDialog=rowInDialog+1;
            colSpan=[1,3];
            OutputTimeStampField=tamslgate('privateslwidgetcheckbox',sprintf('Output Timestamp'),...
            DIOWidgetTags.OutputTimestamp,[rowInDialog,rowInDialog],...
            colSpan,'daqblks.daqslcallback');
            OutputTimeStampField.Mode=true;
        end


        if strcmp(obj.Lines,'')||strcmp(obj.Device,'(none)')||...
            ~channelDataGenereatedFromObject
            SelectAll.Enabled=false;
            UnselectAll.Enabled=false;
            LineTable.Enabled=false;
            NPortsMenu.Enabled=false;
            BlockSampleTimeField.Enabled=false;
            if obj.IsDigitalInput
                OutputTimeStampField.Enabled=false;
            end
        end


        items={DaqDeviceMenu,TableHeaderText,SelectAll,...
        UnselectAll,LineTable,NPortsMenu,BlockSampleTimeField};
        if obj.IsDigitalInput
            items=[items,OutputTimeStampField];
        end
        colSpan=[1,3];
        parameterPane=tamslgate('privateslwidgetgroup','Parameters',DIOWidgetTags.ParameterPane,...
        items,[2,2],colSpan,[rowInDialog,3]);
        parameterPane.ColSpan=[1,3];
        parameterPane.RowStretch=zeros(1,rowInDialog);
        parameterPane.ColStretch=[0,1,0];


        function LineTable=localCreateTable(obj,existDAQObject,DIOWidgetTags)



            localGenerateTableInfo(obj,existDAQObject);
            data='';

            LineTable=tamslgate('privateslwidgetbasestruct','table','',DIOWidgetTags.LineTable);


            if~strcmp(obj.Lines,'')
                for nRow=1:length(obj.LinesSchema)
                    source=obj.LinesSchema(nRow);

                    RowCheckbox=tamslgate('privateslwidgetbasestruct','checkbox',...
                    '','CheckBoxValue');
                    RowCheckbox.Mode=true;
                    RowCheckbox.ObjectProperty='CheckBoxValue';
                    RowCheckbox.Source=source;
                    data{nRow,1}=RowCheckbox;


                    HWLineIDField=tamslgate('privateslwidgetbasestruct','edit',...
                    sprintf('LineID%d',nRow),'HWLineID');
                    HWLineIDField.Mode=true;
                    HWLineIDField.ObjectProperty='HWLineID';
                    HWLineIDField.Source=source;
                    data{nRow,2}=HWLineIDField;


                    NameField=tamslgate('privateslwidgetbasestruct','edit',...
                    sprintf('LineName%d',nRow),'Name');
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

                end
                LineTable.Size=[length(obj.LinesSchema),4];
            else
                LineTable.Size=[0,4];
            end

            LineTable.Grid=true;
            LineTable.Editable=true;
            LineTable.RowSpan=[3,3];
            LineTable.ColSpan=[1,3];

            LineTable.ColHeader={sprintf(' '),sprintf('Line ID'),...
            sprintf('Name'),sprintf('Module')};
            LineTable.ColumnCharacterWidth=[2,11,11,8];

            LineTable.ColumnHeaderHeight=2;
            LineTable.HeaderVisibility=[0,1];
            LineTable.RowHeaderWidth=0;
            LineTable.Alignment=0;
            LineTable.ReadOnlyColumns=[1,3];
            LineTable.MinimumSize=[250,120];
            LineTable.MaximumSize=[1500,720];
            LineTable.ValueChangedCallback=@localCellValueChanged;
            LineTable.Data=data;


            function localCellValueChanged(dialog,row,column,value)
                obj=dialog.getDialogSource;



                rowIndex=row+1;
                colIndex=column+1;


                errorStrings=daqblks.internal.getString('ErrorStrings');


                DIOWidgetTags=daqblks.internal.getString('DIOTags');

                if obj.IsDigitalInput
                    channelType='DigitalInput';
                else
                    channelType='DigitalOutput';
                end

                if~isvalid(obj.DAQObject)


                    errmsg=sprintf(errorStrings.ObjectDeleted,obj.Block.getFullName);
                    uiwait(errordlg(errmsg));
                    return;
                end

                [checkBoxSelection,hwID,name,module]=...
                daqblks.internal.parseAndUpdateTable(obj.Lines,obj.subSystemType);


                currentRowInfo=obj.LinesSchema(rowIndex);

                currentChannelID=currentRowInfo.HWLineID;
                currentDeviceID=currentRowInfo.Module;
                currentChannelIdx=daqblks.internal.locateChannelIndexInSession(obj.DAQObject,currentChannelID,currentDeviceID);
                vendorID=obj.DAQObject.Vendor.ID;
                switch(column)
                case 0

                    if(checkBoxSelection(rowIndex)==value)
                        return;
                    end


                    errmsg='';
                    if(value==0)
                        try



                            if~isempty(currentChannelIdx)
                                obj.DAQObject.removeChannel(currentChannelIdx);
                            end

                            obj.NLinesSelected=num2str(str2double(obj.NLinesSelected)-1);
                        catch exception
                            errmsg=exception.message;
                        end
                    else
                        oldCheckBoxSelection=checkBoxSelection;
                        try
                            checkBoxSelection(rowIndex)=value;



                            delete(obj.DAQObject);
                            obj.DAQObject=daq.createSession(vendorID);


                            daqblks.internal.addChannels(obj.DAQObject,channelType,obj.channelInfoList,...
                            checkBoxSelection,hwID,module);

                            obj.NLinesSelected=num2str(str2double(obj.NLinesSelected)+1);
                        catch exception




                            if any(oldCheckBoxSelection~=0)
                                delete(obj.DAQObject);
                                obj.DAQObject=daq.createSession(vendorID);
                                daqblks.internal.addChannels(obj.DAQObject,channelType,obj.channelInfoList,...
                                oldCheckBoxSelection,hwID,module);
                            end
                            errmsg=exception.message;
                        end
                    end

                    if~isempty(errmsg)

                        tamslgate('privatesldialogbox',dialog,...
                        errmsg,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(DIOWidgetTags.LineTable,row,column,num2str(checkBoxSelection(rowIndex)));
                        return;
                    end
                    currentRowInfo.CheckBoxValue=value;
                case 1
                case 2
                    if strcmp(name{rowIndex},value)
                        return;
                    end
                    if(~isempty(strfind(value,'$'))||~isempty(strfind(value,'#')))

                        tamslgate('privatesldialogbox',dialog,...
                        errorStrings.DigitalLineName,...
                        errorStrings.ErrorDialogTitle);

                        dialog.setTableItemValue(DIOWidgetTags.LineTable,row,column,name{rowIndex});
                        return;
                    end
                    currentRowInfo.Name=value;
                case 3
                end
                obj.Lines=daqblks.internal.parseAndUpdateTable(obj.Lines,rowIndex,colIndex,value);


                function localGenerateTableInfo(obj,existDAQObject)


                    if(~strcmp(obj.Lines,'')&&(~existDAQObject))
                        [checkBoxSelection,hwID,name,module]=...
                        daqblks.internal.parseAndUpdateTable(obj.Lines,obj.subSystemType);

                        for idx=1:length(hwID)
                            channelInfo={num2str(checkBoxSelection(idx));hwID{idx};name{idx};...
                            module{idx}};





                            if(idx==1)
                                obj.LinesSchema=daqdialog.tabledlg(channelInfo,obj.subSystemType);
                            else
                                obj.LinesSchema(idx)=daqdialog.tabledlg(channelInfo,obj.subSystemType);
                            end
                        end
                    end


                    function localAddChannels(obj,allDeviceList,measurementType,existDAQObject)


                        if strcmp(obj.Device,'(none)')||isempty(obj.DAQObject)
                            obj.Lines='';
                            return;
                        end
                        checkClockSupport=-1;

                        obj.channelInfoList=daqblks.internal.getChannelInfo(allDeviceList,obj.Device,obj.subSystemType,checkClockSupport,measurementType);


                        if obj.IsDigitalInput
                            channelType='DigitalInput';
                        else
                            channelType='DigitalOutput';
                        end
                        if~existDAQObject
                            if obj.IsDifferentDevice

                                daqblks.internal.addChannels(obj.DAQObject,channelType,obj.channelInfoList);


                                tableData=daqblks.internal.populateTable(obj.DAQObject,obj.channelInfoList,obj.subSystemType);
                                obj.NLinesSelected=num2str(length(obj.channelInfoList));
                                obj.Lines=tableData;
                            else


                                [checkBoxSelections,hwIDs,~,modules]=...
                                daqblks.internal.parseAndUpdateTable(obj.Lines,obj.subSystemType);
                                daqblks.internal.addChannels(obj.DAQObject,channelType,obj.channelInfoList,...
                                checkBoxSelections,hwIDs,modules);
                            end
                        end

