function dlgStruct=getDialogSchema(obj,~)













    rowSpan=[1,1];
    colSpan=[1,3];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    paramPane=localCreateParamGroup();


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'instrumentslcbpreapply','instrumentslcbclosedialog');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if isLibrary&&isLocked||any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    end

    function paramPane=localCreateParamGroup()


        rowInDialog=1;


        widgetTags=instrumentslgate('privateinstrumentslstring','udpsb');


        colSpan=[1,3];
        HostField=tamslgate('privateslwidgetedit',sprintf('Remote address: '),widgetTags.Host,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        HostField.Mode=true;


        rowInDialog=rowInDialog+1;
        PortField=tamslgate('privateslwidgetedit',sprintf('Remote port:      '),widgetTags.Port,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        NoteUDPSendBlkTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:noteUDPSendBlk')),...
        widgetTags.NoteUDPSendBlk,...
        [rowInDialog,rowInDialog],colSpan);

        NoteUDPSendBlkTextField.Alignment=5;

        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        NoteClkHelpTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:noteClkHelpText')),...
        widgetTags.NoteClkHelpText,...
        [rowInDialog,rowInDialog],colSpan);

        NoteClkHelpTextField.Alignment=5;


        colSpan=[1,3];
        rowInDialog=rowInDialog+1;
        LocalAddressField=tamslgate('privateslwidgetedit',sprintf('Local address:     '),widgetTags.LocalAddress,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        LocalAddressField.Mode=true;


        colSpan=[1,2];
        rowInDialog=rowInDialog+1;
        LocalPortField=tamslgate('privateslwidgetedit',sprintf('Local port:          '),widgetTags.LocalPort,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');

        colSpan=[3,3];
        AutoAssignTextField=tamslgate('privateslwidgettext',...
        getString(message('instrument:instrumentblks:localPortAutoAssignment')),...
        widgetTags.AutoAssignText,...
        [rowInDialog,rowInDialog],colSpan);

        AutoAssignTextField.Alignment=6;


        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        EnablePortSharingCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Enable local port sharing'),widgetTags.EnablePortSharing,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        EnablePortSharingCheckbox.Mode=true;


        rowInDialog=rowInDialog+1;

        colSpan=[1,1];
        CheckValidityButton=tamslgate('privateslwidgetpushbutton',...
        sprintf('Verify address and port connectivity...'),widgetTags.CheckValidity,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        OutputDatagramPacketSize=tamslgate('privateslwidgetedit',sprintf('UDP packet size: '),widgetTags.OutputDatagramPacketSize,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        entries={'BigEndian','LittleEndian'};
        ByteOrderField=tamslgate('privateslwidgetcombo',...
        sprintf('Byte order:         '),widgetTags.ByteOrder,...
        entries,[rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        ByteOrderField.Mode=true;


        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        EnableBlockingModeCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Enable blocking mode'),widgetTags.EnableBlockingMode,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        EnableBlockingModeCheckbox.Mode=true;


        items={HostField,PortField,NoteUDPSendBlkTextField,NoteClkHelpTextField,LocalAddressField,LocalPortField,...
        AutoAssignTextField,EnablePortSharingCheckbox,CheckValidityButton,OutputDatagramPacketSize,...
        ByteOrderField,EnableBlockingModeCheckbox};

        paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
        items,[2,2],[1,3],[rowInDialog+1,3]);







