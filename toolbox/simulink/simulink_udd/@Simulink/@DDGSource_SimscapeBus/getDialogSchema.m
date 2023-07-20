
function dlgStruct=getDialogSchema(this,~)

    blkHandle=this.getBlock.Handle;
    blkDescription=this.getBlock.BlockDescription;

    parent=get_param(blkHandle,'Parent');
    all_editors=GLUE2.Util.findAllEditors(parent);
    if isempty(all_editors)
        DAStudio.error('Simulink:blocks:SimscapeBlockDialogWithoutEditor',get_param(blkHandle,'Name'));
    end


    portStrings=get_param(blkHandle,'hierStrings');
    hierStrings=strsplit(portStrings,';');



    this.UserData1.PortStrings=portStrings;
    this.UserData1.PortConnectivity=get_param(blkHandle,'PortConnectivity');

    if(~isfield(this.UserData1,'SelectedRow'))
        this.UserData1.SelectedRow=[];
    end


    text1.Type='text';
    text1.Name=blkDescription;
    text1.Bold=false;
    text1.RowSpan=[1,1];
    text1.ColSpan=[1,3];
    text1.WordWrap=true;


    container1.Type='group';
    container1.Name=this.getBlock.BlockType;
    container1.Items={text1};
    container1.LayoutGrid=[1,3];


    if isempty(hierStrings{1,1})
        numberOfPorts=0;
    else
        numberOfPorts=numel(hierStrings);
    end

    if~isfield(this.UserData1,'LineInfo')
        this.UserData1.LineInfo=[];
    end
    lineInfo=this.UserData1.LineInfo;
    portHandles=get_param(blkHandle,'PortHandles');
    for i=1:numberOfPorts
        line=get_param(portHandles.LConn(i),'Line');
        lineInfo(i).line=line;
        if line~=-1
            lineInfo(i).isConnected=get_param(line,'Connected');
        else
            lineInfo(i).isConnected='empty';
        end
    end
    this.UserData1.LineInfo=lineInfo;
    modelName=get_param(blkHandle,'Parent');


    text2.Type='text';
    text2.Tag='EmptySpreadsheetText';
    text2.Name=DAStudio.message('Simulink:blkprm_prompts:NoPortsToDisplayInSpreadsheet');
    text2.WordWrap=true;
    text2.Bold=false;
    text2.RowSpan=[1,1];
    text2.ColSpan=[1,3];


    physmodSpreadsheet.Type='spreadsheet';
    physmodSpreadsheet.Columns={DAStudio.message('Simulink:blkprm_prompts:HierarchyStrings')};
    physmodSpreadsheet.RowSpan=[1,(numberOfPorts)];
    physmodSpreadsheet.ColSpan=[1,2];
    physmodSpreadsheet.Source=PhysmodSpreadSheet(this,blkHandle,modelName);
    physmodSpreadsheet.Tag='SimscapeSpreadsheet';
    physmodSpreadsheet.SelectionChangedCallback=@(tag,sels,dlg)onSpreadsheetSelectionChanged(tag,sels,dlg);
    physmodSpreadsheet.Size=[300,300];

    physmodSpreadsheet.Config=jsonencode(struct('enablesort',false,...
    'enablegrouping',false));

    physmodSpreadsheet.Graphical=true;


    if~isempty(portStrings)
        physmodSpreadsheet.Visible=true;
        text2.Visible=false;
    else
        physmodSpreadsheet.Visible=false;
        text2.Visible=true;
    end

    iconPath=fullfile(matlabroot,'toolbox','simulink','simulink_udd',...
    '@Simulink','@DDGSource_SimscapeBus');



    addPortIcon.Type='pushbutton';
    addPortIcon.Tag='Add';
    addPortIcon.FilePath=fullfile(iconPath,'addSimscapePort.png');
    addPortIcon.ToolTip=DAStudio.message('Simulink:blkprm_prompts:AddSimscapeBusPort');
    addPortIcon.DialogRefresh=true;
    addPortIcon.Bold=true;
    addPortIcon.RowSpan=[1,1];
    addPortIcon.ColSpan=[1,1];
    addPortIcon.Alignment=1;
    addPortIcon.MaximumSize=[50,100];
    addPortIcon.MatlabMethod='addPortCallback';
    addPortIcon.MatlabArgs={'%dialog',blkHandle};
    addPortIcon.Enabled=true;



    deletePortIcon.Type='pushbutton';
    deletePortIcon.Tag='Delete';
    deletePortIcon.FilePath=fullfile(iconPath,'deleteSimscapePort.png');
    deletePortIcon.DialogRefresh=true;
    deletePortIcon.Bold=true;
    deletePortIcon.RowSpan=[1,1];
    deletePortIcon.ColSpan=[2,2];
    deletePortIcon.Alignment=1;
    deletePortIcon.MaximumSize=[50,100];
    deletePortIcon.MatlabMethod='deletePortCallback';
    deletePortIcon.MatlabArgs={'%dialog',blkHandle};



    if~isempty(portStrings)




        if(numberOfPorts<=this.UserData1.SelectedRow)
            this.UserData1.SelectedRow=[];
        end
        if(isSelectedPortUnconnected(blkHandle,this.UserData1.SelectedRow))
            deletePortIcon.Enabled=true;
            deletePortIcon.ToolTip=DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusPort');
        else
            deletePortIcon.Enabled=false;
            deletePortIcon.ToolTip=DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusForConnectedPort');
        end
    else
        deletePortIcon.Enabled=false;
        deletePortIcon.ToolTip=DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusPort');
    end




    refreshIcon.Type='pushbutton';
    refreshIcon.Tag='Refresh';
    refreshIcon.Bold=true;
    refreshIcon.MatlabMethod='refreshDialogCallback';
    refreshIcon.MatlabArgs={'%dialog','%tag'};
    refreshIcon.FilePath=fullfile(iconPath,'refreshSimscapeBusDialog.png');
    refreshIcon.ToolTip=DAStudio.message('Simulink:blkprm_prompts:RefreshSimscapeBusDialog');
    refreshIcon.Alignment=1;
    refreshIcon.Enabled=true;
    refreshIcon.MaximumSize=[50,100];
    refreshIcon.RowSpan=[1,1];
    refreshIcon.ColSpan=[3,3];



    spacer.Type='panel';


    iconContainer.Type='panel';
    iconContainer.LayoutGrid=[1,4];
    iconContainer.ColSpan=[1,2];
    iconContainer.RowSpan=[1,1];
    iconContainer.ColStretch=[0,0,0,1];
    iconContainer.RowStretch=0;
    iconContainer.Items={addPortIcon,deletePortIcon,refreshIcon,spacer};

    dlg=this.getOpenDialogs;
    if slfeature('CUSTOM_BUSES')==1


        if(isempty(dlg)||this.UserData1.shouldComputeHierStringSuggestions)
            this.UserData1.HierStringSuggestions=slprivate('slBusCompletions',blkHandle);
            this.UserData1.shouldComputeHierStringSuggestions=false;
        end


        specifyInterfaceText.Name=DAStudio.message('Simulink:blkprm_prompts:BusTypeFromBusObject');
        specifyInterfaceText.Type='text';
        specifyInterfaceText.RowSpan=[1,1];
        specifyInterfaceText.ColSpan=[1,3];
        specifyInterfaceText.Tag='lockBus';
        specifyInterfaceText.WordWrap=true;

        paramName='ConnectionType';
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('Auto');
        dataTypeItems.allowsExpression=false;
        dataTypeItems.supportsConnectionBusType=true;
        specifyInterface=Simulink.DataTypePrmWidget.getDataTypeWidget(this,...
        paramName,...
        '',...
        paramName,...
        get_param(blkHandle,paramName),...
        dataTypeItems,...
        false);
        specifyInterface.RowSpan=[2,2];
        specifyInterface.ColSpan=[1,3];

        specifyInterfaceItems=specifyInterface.Items;
        DTAGroupIdx=strcmp(cellfun(@(elem)elem.Tag,specifyInterfaceItems,'UniformOutput',false),[paramName,'|UDTDataTypeAssistGrp']);
        specifyInterface.Items{DTAGroupIdx}.Name=erase(specifyInterface.Items{DTAGroupIdx}.Name,'Data ');
        DTAOpenIdx=strcmp(cellfun(@(elem)elem.Tag,specifyInterfaceItems,'UniformOutput',false),[paramName,'|UDTShowDataTypeAssistBtn']);
        specifyInterface.Items{DTAOpenIdx}.ToolTip=erase(specifyInterface.Items{DTAOpenIdx}.ToolTip,'data ');
        DTACloseIdx=strcmp(cellfun(@(elem)elem.Tag,specifyInterfaceItems,'UniformOutput',false),[paramName,'|UDTHideDataTypeAssistBtn']);
        specifyInterface.Items{DTACloseIdx}.ToolTip=erase(specifyInterface.Items{DTACloseIdx}.ToolTip,'data ');



        specifyInterface.Items{DTACloseIdx}.DialogRefresh=true;
        if isfield(specifyInterfaceItems{DTAGroupIdx},'Items')
            DTAModeIdx=strcmp(cellfun(@(elem)elem.Tag,specifyInterfaceItems{DTAGroupIdx}.Items,'UniformOutput',false),[paramName,'|UDTDataTypeSpecMethodRadio']);
            specifyInterface.Items{DTAGroupIdx}.Items{DTAModeIdx}.DialogRefresh=true;
        end


        interfaceContainer.Type='group';
        interfaceContainer.LayoutGrid=[2,3];
        interfaceContainer.RowStretch=[0,1];
        interfaceContainer.Items={specifyInterfaceText,specifyInterface};
    end


    hierarchyStringContainer.Type='group';
    hierarchyStringContainer.Items={text2,physmodSpreadsheet};
    hierarchyStringContainer.LayoutGrid=[(max(1,numberOfPorts)),1];
    hierarchyStringContainer.RowSpan=[2,2];
    hierarchyStringContainer.ColSpan=[1,3];
    hierarchyStringContainer.ColStretch=1;


    container2.Type='group';
    container2.Items={iconContainer,hierarchyStringContainer};
    container2.LayoutGrid=[2,3];
    container2.ColStretch=[0,0,0];
    container2.RowStretch=[0,1];


    if slfeature('CUSTOM_BUSES')==1
        dlgStruct.Items={container1,interfaceContainer,container2};
        dlgStruct.LayoutGrid=[3,3];
        dlgStruct.RowStretch=[0,0,1];
    else
        dlgStruct.Items={container1,container2};
        dlgStruct.LayoutGrid=[2,4];
        dlgStruct.RowStretch=[0,1];
    end
    dlgStruct.DialogRefresh=true;
    dlgStruct.DialogTag='SimscapeBus';
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
    if slfeature('CUSTOM_BUSES')==1
        dlgStruct.PreApplyMethod='preApplyCallback';
        dlgStruct.PreApplyArgs={'%dialog'};
        dlgStruct.PreApplyArgsDT={'handle'};
    end
    dlgStruct.HelpMethod='displaySimscapeBusHelp';
    dlgStruct.HelpArgs={blkHandle};
    dlgStruct.HelpArgsDT={'double'};

    if slfeature('CUSTOM_BUSES')==0
        if~isempty(dlg)
            if dlg{1,1}.hasUnappliedChanges
                dlg{1,1}.apply;
            end
        end
    end

    [isLib,isLocked]=this.isLibraryBlock(blkHandle);
    simStatus=get_param(bdroot(blkHandle),'SimulationStatus');

    if~isLib&&(isLocked||this.isHierarchySimulating)||...
        any(strcmp(simStatus,{'running','paused'}))
        if~isempty(dlg)
            dlg{1,1}.setEnabled('SimscapeSpreadsheet',false);
        end
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
end




function r=onSpreadsheetSelectionChanged(~,sels,dlg)


    if numel(sels)>1
        dlg.setEnabled('Add',false);
        dlg.setEnabled('Delete',false);
        dlg.updateToolTip('Delete',DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusForMultiSelection'));
        return;
    else
        dlg.setEnabled('Add',true);
    end

    selectedRow=sels{1}.portNumber;

    dlgSource=dlg.getDialogSource;

    dlgSource.UserData1.SelectedRow=selectedRow;

    blockHandle=sels{1}.blockHandle;

    if(isSelectedPortUnconnected(blockHandle,selectedRow))
        dlg.setEnabled('Delete',true);
        dlg.updateToolTip('Delete',DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusPort'));
    else
        dlg.setEnabled('Delete',false);
        dlg.updateToolTip('Delete',DAStudio.message('Simulink:blkprm_prompts:DeleteSimscapeBusForConnectedPort'));
    end
end



function res=isSelectedPortUnconnected(blkHandle,portNumber)
    res=false;

    if isempty(portNumber)
        portNumber=1;
    end

    portHandles=get_param(blkHandle,'PortHandles');
    selectedPortHandle=portHandles.LConn(portNumber);
    line=get_param(selectedPortHandle,'Line');

    if line==-1
        res=true;
    end
end
