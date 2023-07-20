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


        widgetTags=instrumentslgate('privateinstrumentslstring','tcpipsb');


        colSpan=[1,3];
        HostField=tamslgate('privateslwidgetedit',sprintf('Remote address: '),widgetTags.Host,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        HostField.Mode=true;


        rowInDialog=rowInDialog+1;
        PortField=tamslgate('privateslwidgetedit',sprintf('Port:                  '),widgetTags.Port,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        rowInDialog=rowInDialog+1;

        colSpan=[1,1];
        CheckValidityButton=tamslgate('privateslwidgetpushbutton',...
        sprintf('Verify address and port connectivity...'),widgetTags.CheckValidity,...
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


        rowInDialog=rowInDialog+1;
        colSpan=[1,3];
        TimeoutField=tamslgate('privateslwidgetedit',sprintf('     Timeout:       '),widgetTags.Timeout,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');


        TimeoutField.Enabled=obj.EnableBlockingMode;


        rowInDialog=rowInDialog+1;
        colSpan=[1,1];
        TransferDelayCheckbox=tamslgate('privateslwidgetcheckbox',...
        sprintf('Transfer Delay'),widgetTags.TransferDelay,...
        [rowInDialog,rowInDialog],colSpan,'instrumentslcallback');
        TransferDelayCheckbox.Mode=true;


        items={HostField,PortField,CheckValidityButton,ByteOrderField,...
        EnableBlockingModeCheckbox,TimeoutField,TransferDelayCheckbox};

        paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),widgetTags.ParameterPane,...
        items,[2,2],[1,3],[rowInDialog+1,3]);







