function dlgStruct=PMIOPort_ddg(source,h)




    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.RowSpan=[1,1];
    descTxt.ColSpan=[1,1];
    descTxt.WordWrap=true;

    descGrp.Name=DAStudio.message('Simulink:dialog:ConnPortName');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.LayoutGrid=[1,1];
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    portNumLbl.Name=DAStudio.message('Simulink:blkprm_prompts:PMCPortNumber');
    portNumLbl.Type='text';
    portNumLbl.RowSpan=[1,1];
    portNumLbl.ColSpan=[1,1];
    portNumLbl.Tag='PortLbl';

    portNum.Name=portNumLbl.Name;
    portNum.Type='edit';
    portNum.RowSpan=[1,1];
    portNum.ColSpan=[1,1];
    portNum.ObjectProperty='Port';
    portNum.Tag=portNum.ObjectProperty;

    portNum.MatlabMethod='slDialogUtil';
    portNum.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    portSideLbl.Name=DAStudio.message('Simulink:blkprm_prompts:PMCPortLocation');
    portSideLbl.Type='text';
    portSideLbl.RowSpan=[3,3];
    portSideLbl.ColSpan=[1,1];
    portSideLbl.Tag='SideLbl';

    portSide.Name=portSideLbl.Name;
    portSide.RowSpan=[2,2];
    portSide.ColSpan=[1,1];
    portSide.Type='combobox';
    portSide.Entries={DAStudio.message('Simulink:dialog:Left_CB'),DAStudio.message('Simulink:dialog:Right_CB')};
    portSide.ObjectProperty='Side';
    portSide.Tag=portSide.ObjectProperty;
    portSide.Mode=1;

    portSide.MatlabMethod='slDialogUtil';
    portSide.MatlabArgs={source,'sync','%dialog','combobox','%tag'};

    if slfeature('CUSTOM_BUSES')==1
        lockInterface.Name=DAStudio.message('Simulink:blkprm_prompts:BusTypeFromBusObject');
        lockInterface.Type='text';
        lockInterface.RowSpan=[1,1];
        lockInterface.ColSpan=[1,1];
        lockInterface.Tag='lockBus';

        paramName='ConnectionType';
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('Auto');
        dataTypeItems.allowsExpression=false;
        dataTypeItems.supportsConnectionBusType=true;
        dataTypeItems.supportsConnectionType=true;
        portType=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
        paramName,...
        '',...
        paramName,...
        get_param(source,paramName),...
        dataTypeItems,...
        false);
        portType.Items{1}.Name=lockInterface.Name;
        portType.Items{1}.HideName=1;
        portType.RowSpan=[2,2];
        portType.ColSpan=[1,1];

        portTypeItems=portType.Items;
        DTAGroupIdx=strcmp(cellfun(@(elem)elem.Tag,portTypeItems,'UniformOutput',false),[paramName,'|UDTDataTypeAssistGrp']);
        portType.Items{DTAGroupIdx}.Name=erase(portType.Items{DTAGroupIdx}.Name,'Data ');
        DTAOpenIdx=strcmp(cellfun(@(elem)elem.Tag,portTypeItems,'UniformOutput',false),[paramName,'|UDTShowDataTypeAssistBtn']);
        portType.Items{DTAOpenIdx}.ToolTip=erase(portType.Items{DTAOpenIdx}.ToolTip,'data ');
        DTACloseIdx=strcmp(cellfun(@(elem)elem.Tag,portTypeItems,'UniformOutput',false),[paramName,'|UDTHideDataTypeAssistBtn']);
        portType.Items{DTACloseIdx}.ToolTip=erase(portType.Items{DTACloseIdx}.ToolTip,'data ');



        portType.Items{DTACloseIdx}.DialogRefresh=true;
        if isfield(portTypeItems{DTAGroupIdx},'Items')
            DTAModeIdx=strcmp(cellfun(@(elem)elem.Tag,portTypeItems{DTAGroupIdx}.Items,'UniformOutput',false),[paramName,'|UDTDataTypeSpecMethodRadio']);
            portType.Items{DTAGroupIdx}.Items{DTAModeIdx}.DialogRefresh=true;
        end


        physmodHyperlink.Name=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLink');
        physmodHyperlink.Type='hyperlink';
        physmodHyperlink.Tag='physmodHyperlink';
        physmodHyperlink.MatlabMethod='helpview';
        physmodHyperlink.MatlabArgs={'simscape','DomainLineStyles'};
        physmodHyperlink.RowSpan=[3,3];
        physmodHyperlink.ColSpan=[1,1];
        physmodHyperlink.Enabled=true;
        physmodHyperlink.ToolTip=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLinkTooltip');
        physmodHyperlink.Alignment=1;

        blankWidget.Type='panel';
        blankWidget.RowSpan=[3,3];
        blankWidget.ColSpan=[1,1];



        interfaceContainer.Type='group';
        interfaceContainer.LayoutGrid=[3,1];
        interfaceContainer.RowSpan=[3,3];
        interfaceContainer.ColSpan=[1,1];
        interfaceContainer.Items={lockInterface,portType,physmodHyperlink};
    end

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    if slfeature('CUSTOM_BUSES')==1
        paramGrp.Items={portNum,portSide,interfaceContainer};
        paramGrp.LayoutGrid=[3,1];
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
    else
        paramGrp.Items={portNumLbl,portNum,portSideLbl,portSide};
        paramGrp.LayoutGrid=[3,2];
    end
    paramGrp.Source=h;

    blkHandle=source.getBlock.Handle;
    [isLib,isLocked]=source.isLibraryBlock(blkHandle);
    simStatus=get_param(bdroot(blkHandle),'SimulationStatus');
    if~isLib&&(isLocked||source.isHierarchySimulating)||...
        any(strcmp(simStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    else
        dlgStruct.DisableDialog=false;
    end

    dlgStruct.Items={descGrp,paramGrp,blankWidget};
    dlgStruct.DialogRefresh=true;
    dlgStruct.LayoutGrid=[3,1];
    dlgStruct.RowStretch=[0,0,1];
    dlgStruct.DialogTag='PMIOPort';
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
