function dlgStruct=getDialogSchema(obj,~)













    rowSpan=[1,1];
    colSpan=[1,3];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateParamGroup(obj);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'instrumentslcbpreapply','instrumentslcbclosedialog');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if isLibrary&&isLocked||any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    end

    function paramPane=localCreateParamGroup(obj)


        rowInDialog=1;


        widgetTags=instrumentslgate('privateinstrumentslstring','udprb');


        colSpan=[1,2];
        rowInDialog=rowInDialog+1;
        LocalAddressField=tamslgate('privateslwidgetedit',sprintf('Local address:    '),widgetTags.LocalAddress,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        LocalAddressField.Mode=true;


        colSpan=[1,1];
        rowInDialog=rowInDialog+1;
        LocalPortField=tamslgate('privateslwidgetedit',sprintf('Local port:         '),widgetTags.LocalPort,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');

        colSpan=[2,2];
        AutoAssignTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:localPortAutoAssignment')),...
        widgetTags.AutoAssignText,...
        [rowInDialog,rowInDialog],colSpan);

        AutoAssignTextField.Alignment=6;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        EnablePortSharingCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Enable local port sharing'),widgetTags.EnablePortSharing,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        EnablePortSharingCheckbox.Mode=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        NoteUDPReceiveBlkTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:noteUDPReceiveBlk')),...
        widgetTags.NoteUDPReceiveBlk,...
        [rowInDialog,rowInDialog],colSpan);

        NoteUDPReceiveBlkTextField.Alignment=5;

        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        NoteClkHelpTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:noteClkHelpText')),...
        widgetTags.NoteClkHelpText,...
        [rowInDialog,rowInDialog],colSpan);

        NoteClkHelpTextField.Alignment=5;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        HostField=tamslgate('privateslwidgetedit',sprintf('Remote address: '),widgetTags.Host,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        HostField.Mode=true;


        colSpan=[1,2];
        rowInDialog=rowInDialog+1;
        PortField=tamslgate('privateslwidgetedit',sprintf('Remote port:      '),widgetTags.Port,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;

        colSpan=[1,1];
        CheckValidityButton=tamslgate('privateslwidgetpushbutton',...
        sprintf('Verify address and port connectivity...'),widgetTags.CheckValidity,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        GetLatestDataCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Output latest data'),widgetTags.GetLatestData,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        GetLatestDataCheckbox.Mode=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        DataSizeField=tamslgate('privateslwidgetedit',sprintf('Data size:              '),widgetTags.DataSize,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;
        entries={'single','double','int8','uint8',...
        'int16','uint16','int32','uint32','ASCII'};
        DataTypeCombo=tamslgate('privateslwidgetcombo',sprintf('Source Data type:          '),...
        widgetTags.DataType,entries,[rowInDialog,rowInDialog],...
        colSpan,'instrumentslcallback');
        DataTypeCombo.Mode=true;
        DataTypeCombo.DialogRefresh=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        ASCIIFormattingField=tamslgate('privateslwidgetedit',sprintf('      ASCII format string: '),widgetTags.ASCIIFormatting,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        ASCIIFormattingField.Enabled=strcmpi(obj.DataType,'ASCII');
        GetLatestDataCheckbox.Enabled=~strcmpi(obj.DataType,'ASCII');


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        TerminatorField=tamslgate('privateslwidgetedit',sprintf('      Terminator:             '),widgetTags.Terminator,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        TerminatorField.Enabled=strcmpi(obj.DataType,'ASCII');


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        entries={'BigEndian','LittleEndian'};
        ByteOrderField=tamslgate('privateslwidgetcombo',...
        sprintf('      Byte order:      '),widgetTags.ByteOrder,...
        entries,[rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        ByteOrderField.Mode=true;
        if strcmpi(obj.DataType,'uint8')||strcmpi(obj.DataType,'int8')
            ByteOrderField.Enabled=false;
        else
            ByteOrderField.Enabled=true;
        end


        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        EnableBlockingModeCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Enable blocking mode'),widgetTags.EnableBlockingMode,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        EnableBlockingModeCheckbox.Mode=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        TimeoutField=tamslgate('privateslwidgetedit',sprintf('    Timeout:           '),widgetTags.Timeout,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        TimeoutField.Enabled=obj.EnableBlockingMode;


        rowInDialog=rowInDialog+1;
        colSpan=[1,2];
        SampleTimeField=tamslgate('privateslwidgetedit',sprintf('Block sample time: '),widgetTags.SampleTime,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        items={LocalAddressField,LocalPortField,AutoAssignTextField,EnablePortSharingCheckbox,NoteUDPReceiveBlkTextField,...
        NoteClkHelpTextField,HostField,PortField,CheckValidityButton,GetLatestDataCheckbox,DataSizeField,DataTypeCombo,...
        ASCIIFormattingField,TerminatorField,ByteOrderField,EnableBlockingModeCheckbox,TimeoutField,SampleTimeField};

        paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
        items,[2,2],[1,3],[rowInDialog+1,3]);







