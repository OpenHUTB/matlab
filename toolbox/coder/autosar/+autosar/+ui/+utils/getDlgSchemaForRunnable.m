




function dlgstruct=getDlgSchemaForRunnable(obj)
    runnableObj=obj.getM3iObject();
    eventsObj=runnableObj.containerM3I.Events;

    colHeaders={DAStudio.message('RTW:autosar:eventTypeStr'),...
    DAStudio.message('RTW:autosar:eventNameStr')};

    eventTable.Tag='AutosarEventConfigurationTable';
    eventTable.Type='table';
    eventTable.Grid=true;
    eventTable.HeaderVisibility=[0,1];
    eventTable.ColHeader=colHeaders;
    eventTable.Mode=true;
    eventTable.DialogRefresh=true;
    eventTable.ColumnCharacterWidth=[25,30];
    eventTable.ColumnHeaderHeight=2;
    eventTable.Editable=true;
    eventTable.ValueChangedCallback=@eventTableUpdateCallback;
    eventTable.CurrentItemChangedCallback=@eventTableItemChanged;
    eventTable.SelectionChangedCallback=@eventTableSelectionChanged;

    rowData={};
    rowID=1;
    numEvents=0;
    build=false;
    opSignatureName='';
    opSigVisible=false;

    m3iObj=obj.getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    if isempty(findprop(arExplorer,'EventData'))
        eventDataProp=schema.prop(arExplorer,'EventData','mxArray');
        eventDataProp.Visible='off';
    end
    if isempty(findprop(arExplorer,'SelectedEventName'))
        selectedEventProp=schema.prop(arExplorer,'SelectedEventName','string');
        selectedEventProp.Visible='off';
    end
    if isempty(findprop(arExplorer,'EventTableColWidth'))
        widthProp=schema.prop(arExplorer,'EventTableColWidth','mxArray');
        widthProp.Visible='off';
    end
    if~isempty(arExplorer.EventTableColWidth)
        eventTable.ColumnCharacterWidth=arExplorer.EventTableColWidth;
    end

    eventData=arExplorer.EventData;

    if~isempty(eventData)

        if~strcmp(eventData(1).RunnableName,runnableObj.Name)
            eventData=[];
            arExplorer.SelectedEventName='';
        end
    end

    eventDataMeta=metaclass(eventData);
    if isempty(eventData)&&strcmp(eventDataMeta.Name,'double')




        build=true;
    end

    if build
        eventSize=eventsObj.size();
        eventData=[];
    else
        eventSize=length(eventData);
    end

    eventPropertiesGroup.Visible=false;

    eventType='';
    for idx=1:eventSize
        if build
            if~isempty(eventsObj.at(idx).StartOnEvent)
                runnableName=eventsObj.at(idx).StartOnEvent.Name;
            else
                runnableName='';
            end
        else
            runnableName=eventData(idx).RunnableName;
        end
        if~strcmp(runnableName,obj.Name)
            continue;
        end
        numEvents=numEvents+1;

        if build
            eventName=eventsObj.at(idx).Name;
            if isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{1})
                eventType=autosar.ui.wizard.PackageString.EventTypes{1};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{2})
                eventType=autosar.ui.wizard.PackageString.EventTypes{2};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{3})
                eventType=autosar.ui.wizard.PackageString.EventTypes{3};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{4})
                eventType=autosar.ui.wizard.PackageString.EventTypes{4};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{5})
                eventType=autosar.ui.wizard.PackageString.EventTypes{5};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{6})
                eventType=autosar.ui.wizard.PackageString.EventTypes{6};
            elseif isa(eventsObj.at(idx),...
                autosar.ui.configuration.PackageString.Events{7})
                eventType=autosar.ui.wizard.PackageString.EventTypes{7};
            elseif(eventsObj.at(idx).MetaClass==Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass)
                eventType='InternalTriggerOccurredEvent';
            else
                assert(false,'Unknown event type');
            end


            autosar.ui.utils.buildOrUpdateEventData(arExplorer,eventsObj.at(idx),[]);
            eventData=arExplorer.EventData;
        else
            eventName=eventData(idx).Name;
            eventType=eventData(idx).EventType;
        end

        eventNameEdit.Type='edit';
        eventNameEdit.Name=eventName;
        eventNameEdit.Value=eventName;
        eventNameEdit.Tag='AutosarEventNameEdit';


        if strcmp(eventType,'InternalTriggerOccurredEvent')
            eventNameEdit.Enabled=false;

            eventTypeComboBox.Type='edit';
            eventTypeComboBox.Enabled=false;
            eventTypeComboBox.Name=eventType;
            eventTypeComboBox.Value=eventType;
        else
            eventTypeComboBox.Type='combobox';
            eventTypeComboBox.Mode=true;
            eventTypeComboBox.Entries=autosar.ui.wizard.PackageString.EventTypes;
            index=find(ismember(autosar.ui.wizard.PackageString.EventTypes,eventType));
            if isempty(index)
                assert(false,'Unknown event type');
            else
                eventTypeComboBox.Value=index-1;
            end
        end

        if~build
            if strcmp(eventData(idx).Name,arExplorer.SelectedEventName)
                if strcmp(eventData(idx).EventType,...
                    {autosar.ui.wizard.PackageString.EventTypes{1},...
                    autosar.ui.wizard.PackageString.EventTypes{5}})
                    eventPropertiesGroup.Visible=false;
                elseif any(strcmp(eventData(idx).EventType,...
                    {autosar.ui.wizard.PackageString.EventTypes{2},...
                    autosar.ui.wizard.PackageString.EventTypes{4},...
                    autosar.ui.wizard.PackageString.EventTypes{6},...
                    autosar.ui.wizard.PackageString.EventTypes{7}}))
                    eventPropertiesGroup.Visible=true;
                    eventTriggerPortComboBox.Visible=true;
                    if strcmp(eventData(idx).EventType,...
                        autosar.ui.wizard.PackageString.EventTypes{4})
                        opSigVisible=true;
                        if~strcmp(eventData(idx).TriggerPort,...
                            DAStudio.message('RTW:autosar:selectERstr'))
                            triggerValue=strsplit(eventData(idx).TriggerPort,'.');
                            opSignatureName=autosar.ui.utils.getOpSignature(arExplorer,...
                            triggerValue(1),triggerValue(2),m3iObj);
                        end
                    end
                    eventModeActivationKindComboBox.Visible=false;
                    eventModeReceiverPortComboBox.Visible=false;
                    exitModeGroup.Visible=false;
                    entryModeGroup.Visible=false;
                    transitionFromModeGroup.Visible=false;
                    transitionIntoModeGroup.Visible=false;
                elseif strcmp(eventData(idx).EventType,...
                    autosar.ui.wizard.PackageString.EventTypes{3})
                    eventPropertiesGroup.Visible=true;
                    eventTriggerPortComboBox.Visible=false;
                    eventModeActivationKindComboBox.Visible=true;
                    eventModeReceiverPortComboBox.Visible=true;
                    switch eventData(idx).Activation
                    case autosar.ui.wizard.PackageString.TransitionTypes{1}
                        entryModeGroup.Visible=true;
                        exitModeGroup.Visible=false;
                        transitionFromModeGroup.Visible=false;
                        transitionIntoModeGroup.Visible=false;
                    case autosar.ui.wizard.PackageString.TransitionTypes{2}
                        entryModeGroup.Visible=false;
                        exitModeGroup.Visible=true;
                        transitionFromModeGroup.Visible=false;
                        transitionIntoModeGroup.Visible=false;
                    case autosar.ui.wizard.PackageString.TransitionTypes{3}
                        exitModeGroup.Visible=false;
                        entryModeGroup.Visible=false;
                        transitionFromModeGroup.Visible=true;
                        transitionIntoModeGroup.Visible=true;
                    case DAStudio.message('RTW:autosar:selectERstr')
                        entryModeGroup.Visible=false;
                        exitModeGroup.Visible=false;
                        transitionFromModeGroup.Visible=false;
                        transitionIntoModeGroup.Visible=false;
                    end
                end
                eventTriggerPortComboBox.Value=i_comboBoxEntryToValue(...
                eventData(idx).ReceiverCellValues,eventData(idx).TriggerPort);
                eventTriggerPortComboBox.Entries=eventData(idx).ReceiverCellValues;
                eventModeActivationKindComboBox.Value=i_comboBoxEntryToValue(...
                eventData(idx).ActivationCellValues,eventData(idx).Activation);
                eventModeActivationKindComboBox.Entries=eventData(idx).ActivationCellValues;
                eventModeReceiverPortComboBox.Value=i_comboBoxEntryToValue(...
                eventData(idx).ModeReceiverPortCellValues,eventData(idx).ModeReceiverPort);
                eventModeReceiverPortComboBox.Entries=eventData(idx).ModeReceiverPortCellValues;
                eventModeDeclarationComboBox1.Value=i_comboBoxEntryToValue(...
                eventData(idx).ModeDeclarationCellValues1,eventData(idx).ModeDeclaration1);
                eventModeDeclarationComboBox1.Entries=eventData(idx).ModeDeclarationCellValues1;
                eventModeDeclarationComboBox2.Value=i_comboBoxEntryToValue(...
                eventData(idx).ModeDeclarationCellValues1,eventData(idx).ModeDeclaration1);
                eventModeDeclarationComboBox2.Entries=eventData(idx).ModeDeclarationCellValues1;
                eventModeDeclarationComboBox3.Value=i_comboBoxEntryToValue(...
                eventData(idx).ModeDeclarationCellValues1,eventData(idx).ModeDeclaration1);
                eventModeDeclarationComboBox3.Entries=eventData(idx).ModeDeclarationCellValues1;
                eventModeDeclarationComboBox4.Value=i_comboBoxEntryToValue(...
                eventData(idx).ModeDeclarationCellValues2,eventData(idx).ModeDeclaration2);
                eventModeDeclarationComboBox4.Entries=eventData(idx).ModeDeclarationCellValues2;
            end
        end
        rowData{rowID,1}=eventTypeComboBox;%#ok<AGROW>
        rowData{rowID,2}=eventNameEdit;%#ok<AGROW>
        rowID=rowID+1;
    end
    eventTable.Size=[numEvents,length(colHeaders)];
    eventTable.Data=rowData;
    eventTable.RowSpan=[3,3];
    eventTable.ColSpan=[1,2];

    eventTriggerPortComboBox.Type='combobox';
    eventTriggerPortComboBox.Mode=true;
    eventTriggerPortComboBox.Name=DAStudio.message('RTW:autosar:TriggerStr');
    eventTriggerPortComboBox.Tag='AutosarTriggerPort';
    eventTriggerPortComboBox.ColSpan=[1,2];
    eventTriggerPortComboBox.RowSpan=[1,1];
    eventTriggerPortComboBox.MatlabMethod='autosar.ui.utils.eventTriggerPortChanged';
    eventTriggerPortComboBox.MatlabArgs={'%dialog'};

    eventModeActivationKindComboBox.Type='combobox';
    eventModeActivationKindComboBox.Tag='AutosarModeActivationKind';
    eventModeActivationKindComboBox.Mode=true;
    eventModeActivationKindComboBox.Name=[DAStudio.message('autosarstandard:ui:uiModeActivationStr'),': '];
    eventModeActivationKindComboBox.ColSpan=[1,2];
    eventModeActivationKindComboBox.RowSpan=[1,1];
    eventModeActivationKindComboBox.MatlabMethod='autosar.ui.utils.modeActivationChanged';
    eventModeActivationKindComboBox.MatlabArgs={'%dialog',obj};

    eventModeReceiverPortComboBox.Type='combobox';
    eventModeReceiverPortComboBox.Mode=true;
    eventModeReceiverPortComboBox.Name=[DAStudio.message('autosarstandard:ui:uiModeReceiverPortStr'),': '];
    eventModeReceiverPortComboBox.Tag='AutosarModeReceiverPort';
    eventModeReceiverPortComboBox.ColSpan=[1,2];
    eventModeReceiverPortComboBox.RowSpan=[2,2];
    eventModeReceiverPortComboBox.MatlabMethod='autosar.ui.utils.modeReceiverPortChanged';
    eventModeReceiverPortComboBox.MatlabArgs={'%dialog',obj};

    eventModeDeclarationComboBox1.Type='combobox';
    eventModeDeclarationComboBox1.Mode=true;
    eventModeDeclarationComboBox1.Name=[DAStudio.message('autosarstandard:ui:uiModeDeclarationStr'),': '];
    eventModeDeclarationComboBox1.Tag='AutosarModeDeclarationRef1';
    eventModeDeclarationComboBox1.ColSpan=[1,2];
    eventModeDeclarationComboBox1.RowSpan=[4,4];
    eventModeDeclarationComboBox1.MatlabMethod='autosar.ui.utils.modeDeclarationChanged';
    eventModeDeclarationComboBox1.MatlabArgs={'%dialog',obj,'1'};

    eventModeDeclarationComboBox2.Type='combobox';
    eventModeDeclarationComboBox2.Mode=true;
    eventModeDeclarationComboBox2.Name=[DAStudio.message('autosarstandard:ui:uiModeDeclarationStr'),': '];
    eventModeDeclarationComboBox2.Tag='AutosarModeDeclarationRef2';
    eventModeDeclarationComboBox2.ColSpan=[1,2];
    eventModeDeclarationComboBox2.RowSpan=[7,7];
    eventModeDeclarationComboBox2.MatlabMethod='autosar.ui.utils.modeDeclarationChanged';
    eventModeDeclarationComboBox2.MatlabArgs={'%dialog',obj,'2'};

    eventModeDeclarationComboBox3.Type='combobox';
    eventModeDeclarationComboBox3.Mode=true;
    eventModeDeclarationComboBox3.Name=[DAStudio.message('autosarstandard:ui:uiModeDeclarationStr'),': '];
    eventModeDeclarationComboBox3.Tag='AutosarModeDeclarationRef3';
    eventModeDeclarationComboBox3.ColSpan=[1,2];
    eventModeDeclarationComboBox3.RowSpan=[4,4];
    eventModeDeclarationComboBox3.MatlabMethod='autosar.ui.utils.modeDeclarationChanged';
    eventModeDeclarationComboBox3.MatlabArgs={'%dialog',obj,'3'};

    eventModeDeclarationComboBox4.Type='combobox';
    eventModeDeclarationComboBox4.Mode=true;
    eventModeDeclarationComboBox4.Name=[DAStudio.message('autosarstandard:ui:uiModeDeclarationStr'),': '];
    eventModeDeclarationComboBox4.Tag='AutosarModeDeclarationRef4';
    eventModeDeclarationComboBox4.ColSpan=[1,2];
    eventModeDeclarationComboBox4.RowSpan=[4,4];
    eventModeDeclarationComboBox4.MatlabMethod='autosar.ui.utils.modeDeclarationChanged';
    eventModeDeclarationComboBox4.MatlabArgs={'%dialog',obj,'4'};

    entryModeGroup.Type='group';
    entryModeGroup.Tag='AutosarOnEntryModeGroupControl';
    entryModeGroup.Name=DAStudio.message('autosarstandard:ui:uiOnEntryStr');
    entryModeGroup.ColSpan=[1,2];
    entryModeGroup.RowSpan=[3,4];
    entryModeGroup.Items={eventModeDeclarationComboBox1};

    exitModeGroup.Type='group';
    exitModeGroup.Tag='AutosarOnExitModeGroupControl';
    exitModeGroup.Name=DAStudio.message('autosarstandard:ui:uiOnExitStr');
    exitModeGroup.ColSpan=[1,2];
    exitModeGroup.RowSpan=[3,4];
    exitModeGroup.Items={eventModeDeclarationComboBox2};

    transitionFromModeGroup.Type='group';
    transitionFromModeGroup.Tag='AutosarTransitionFromModeGroupControl';
    transitionFromModeGroup.Name=DAStudio.message('autosarstandard:ui:uiTransitionFromStr');
    transitionFromModeGroup.ColSpan=[1,2];
    transitionFromModeGroup.RowSpan=[3,4];
    transitionFromModeGroup.Items={eventModeDeclarationComboBox3};

    transitionIntoModeGroup.Type='group';
    transitionIntoModeGroup.Tag='AutosarTransitionIntoModeGroupControl';
    transitionIntoModeGroup.Name=DAStudio.message('autosarstandard:ui:uiTransitionIntoStr');
    transitionIntoModeGroup.ColSpan=[1,2];
    transitionIntoModeGroup.RowSpan=[6,7];
    transitionIntoModeGroup.Items={eventModeDeclarationComboBox4};

    spacer_top.Type='panel';
    spacer_top.ColSpan=[1,2];
    spacer_top.RowSpan=[2,2];
    spacer_top.Visible=opSigVisible;

    opSignatureLabel.Type='text';
    opSignatureLabel.Mode=true;
    opSignatureLabel.Name=[DAStudio.message('autosarstandard:ui:OperationSignature'),':'];
    opSignatureLabel.Tag='OperationSignatureLabel';
    opSignatureLabel.ColSpan=[1,2];
    opSignatureLabel.RowSpan=[3,3];
    opSignatureLabel.Visible=opSigVisible;

    opSignature.Type='text';
    opSignature.Mode=true;
    opSignature.Name=opSignatureName;
    opSignature.Tag='OperationSignatureEdit';
    opSignature.ColSpan=[1,2];
    opSignature.RowSpan=[4,4];
    opSignature.Visible=opSigVisible;

    spacer_right.Type='panel';
    spacer_right.ColSpan=[3,3];
    spacer_right.RowSpan=[1,11];

    spacer_middle.Type='panel';
    spacer_middle.ColSpan=[1,2];
    spacer_middle.RowSpan=[5,5];

    spacer_bottom.Type='panel';
    spacer_bottom.ColSpan=[1,2];
    spacer_bottom.RowSpan=[8,11];

    eventPropertiesGroup.Items={eventTriggerPortComboBox,...
    spacer_top,opSignatureLabel,opSignature,...
    eventModeActivationKindComboBox,eventModeReceiverPortComboBox,...
    exitModeGroup,spacer_middle,entryModeGroup,spacer_bottom,...
    spacer_right,transitionFromModeGroup,transitionIntoModeGroup};

    eventPropertiesGroup.Type='group';
    eventPropertiesGroup.Tag='AutosarEventExtendedGroupControl';
    eventPropertiesGroup.Name=DAStudio.message('autosarstandard:ui:uiEventPropertiesStr');
    eventPropertiesGroup.LayoutGrid=[11,3];
    eventPropertiesGroup.ColSpan=[1,2];
    eventPropertiesGroup.RowSpan=[4,6];


    if build
        arExplorer.EventData=eventData;
    end




    newPushButton.Type='pushbutton';
    newPushButton.Name=DAStudio.message('RTW:autosar:addEventStr');
    newPushButton.ToolTip=DAStudio.message('RTW:autosar:addEventToolTipStr');
    newPushButton.Tag='AutosarEventNew';
    newPushButton.MinimumSize=[50,25];
    newPushButton.MatlabMethod='autosar.ui.utils.addEventToTable';
    newPushButton.MatlabArgs={'%dialog',obj};
    newPushButton.RowSpan=[1,1];
    newPushButton.ColSpan=[1,1];
    newPushButton.Mode=true;

    deletePushButton.Type='pushbutton';
    deletePushButton.Name=DAStudio.message('RTW:autosar:deleteEventStr');
    deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteEventToolTipStr');
    deletePushButton.Tag='AutosarEventDelete';
    deletePushButton.MinimumSize=[50,25];
    deletePushButton.MatlabMethod='autosar.ui.utils.deleteEventFromTable';
    deletePushButton.MatlabArgs={'%dialog',obj};
    deletePushButton.RowSpan=[1,1];
    deletePushButton.ColSpan=[2,2];
    deletePushButton.Mode=true;
    deletePushButton.Enabled=numEvents>0;




    if strcmp(eventType,'InternalTriggerOccurredEvent')
        newPushButton.Enabled=false;
        deletePushButton.Enabled=false;
    end

    eventButtonPanel.Type='panel';
    eventButtonPanel.LayoutGrid=[1,3];
    eventButtonPanel.ColSpan=[1,2];
    eventButtonPanel.RowSpan=[2,2];
    eventButtonPanel.ColStretch=[0,0,1];
    eventButtonPanel.Items={newPushButton,deletePushButton};

    spacer_eventtablebottom.Type='panel';
    spacer_eventtablebottom.ColSpan=[1,2];
    spacer_eventtablebottom.RowSpan=[7,7];

    dlgstruct.ExplicitShow=true;
    dlgstruct.DialogTitle=autosar.ui.wizard.PackageString.EventTableTitle;
    dlgstruct.Items={eventButtonPanel,eventTable,eventPropertiesGroup,spacer_eventtablebottom};
    dlgstruct.LayoutGrid=[7,7];
    dlgstruct.RowStretch=[0,0,1,0,0,0,1];


    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={'Apply'};
    dlgstruct.PreApplyCallback='autosar.ui.utils.eventApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog',m3iObj};
    dlgstruct.PreApplyArgsDT={'handle','handle'};
    dlgstruct.CloseCallback='autosar.ui.utils.closeCallbackForRunnableDlg';
    dlgstruct.CloseArgs={'%dialog',arExplorer};

    dlgstruct.DialogTag='autosar_event_dialog';
end

function eventTableSelectionChanged(dlg,tableTag)
    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));

    row=dlg.getSelectedTableRow(tableTag);
    if row==-1
        dlg.setVisible('AutosarEventExtendedGroupControl',0)
        arExplorer.SelectedEventName='';
    else
        if isempty(arExplorer.SelectedEventName)
            index=-1;
            count=-1;
            eventData=arExplorer.EventData;
            for ii=1:length(eventData)
                if strcmp(eventData(ii).RunnableName,m3iObj.Name)
                    count=count+1;
                    if count==row
                        index=ii;
                        break;
                    end
                end
            end
            arExplorer.SelectedEventName=eventData(index).Name;
            if~strcmp(eventData(index).EventType,autosar.ui.wizard.PackageString.EventTypes{1})&&...
                ~strcmp(eventData(index).EventType,autosar.ui.wizard.PackageString.EventTypes{5})
                dlg.setVisible('AutosarEventExtendedGroupControl',1)
            end
        end
    end
end

function eventTableItemChanged(dlg,row,col)
    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));

    index=-1;
    count=-1;
    eventData=arExplorer.EventData;
    if isempty(eventData)
        dlg.refresh();
        eventData=arExplorer.EventData;
    end
    for ii=1:length(eventData)
        if strcmp(eventData(ii).RunnableName,m3iObj.Name)
            count=count+1;
            if count==row
                index=ii;
                break;
            end
        end
    end
    arExplorer.EventData=eventData;
    arExplorer.SelectedEventName=eventData(index).Name;
    if col==1


        dlg.refresh();
    end
end

function eventTableUpdateCallback(dlg,row,col,val)
    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    index=autosar.ui.utils.getEventIndex(eventData,row,m3iObj.Name);
    arExplorer.SelectedEventName=eventData(index).Name;
    mapping=arExplorer.MappingManager.getActiveMappingFor('AutosarTarget');
    switch col
    case 0

        switch val
        case{1,5}
            m3iComp=m3iObj.containerM3I.containerM3I;
            receiversCell=[{DAStudio.message('RTW:autosar:selectERstr')},...
            autosar.api.Utils.getDataReceivedEventTriggers(m3iComp,mapping)];

            eventData(index).setReceiverCellValues(receiversCell);
            eventData(index).setTriggerPort(DAStudio.message('RTW:autosar:selectERstr'));
        case 6
            m3iComp=m3iObj.containerM3I.containerM3I;
            receiversCell=[{DAStudio.message('RTW:autosar:selectERstr')},...
            autosar.api.Utils.getExternalTriggerOccurredEventTriggers(m3iComp)];

            eventData(index).setReceiverCellValues(receiversCell);
            eventData(index).setTriggerPort(DAStudio.message('RTW:autosar:selectERstr'));
        case 2
            if length(eventData(index).ActivationCellValues)==1

                modeSwitchEventActivationsCell=cell(1,1);
                modeSwitchEventActivationsCell{1}=DAStudio.message('RTW:autosar:selectERstr');
                for i=1:length(autosar.ui.wizard.PackageString.TransitionTypes)
                    modeSwitchEventActivationsCell{end+1}=...
                    autosar.ui.wizard.PackageString.TransitionTypes{i};%#ok<AGROW>
                end
                eventData(index).setActivationCellValues(modeSwitchEventActivationsCell);
            end
            if length(eventData(index).ModeReceiverPortCellValues)==1
                modeReceiverPortsCell=autosar.ui.utils.getModeReceiverPorts(mapping,...
                eventData(index).RunnableName);
                eventData(index).setModeReceiverPortCellValues(modeReceiverPortsCell);
            end
        case 3
            compObj=m3iObj.containerM3I.containerM3I;
            serverPorts=autosar.mm.Model.findChildByTypeName(compObj,...
            autosar.ui.configuration.PackageString.Ports{5},false,false);
            receiversCell=cell(1,1);
            receiversCell{1}=DAStudio.message('RTW:autosar:selectERstr');
            for ii=1:length(serverPorts)
                if serverPorts{ii}.Interface.isvalid()
                    for jj=1:serverPorts{ii}.Interface.Operations.size()
                        receiversCell{end+1}=[serverPorts{ii}.Name,'.'...
                        ,serverPorts{ii}.Interface.Operations.at(jj).Name];%#ok<AGROW>
                    end
                end
            end
            receiversCell=unique(receiversCell,'stable');
            eventData(index).setReceiverCellValues(receiversCell);
            eventData(index).setTriggerPort(DAStudio.message('RTW:autosar:selectERstr'));
        end
        eventType=autosar.ui.wizard.PackageString.EventTypes{val+1};
        eventData(index).setType(eventType);
        dlg.refresh;
    case 1


        modelName=autosar.api.Utils.getModelNameFromMapping(mapping);
        maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
        idcheckmessage=autosar.ui.utils.isValidARIdentifier({val},'shortName',...
        maxShortNameLength);
        if~isempty(idcheckmessage)
            errordlg(DAStudio.message('RTW:autosar:errorInvalidEvent',val,...
            maxShortNameLength),...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            dlg.setTableItemValue('AutosarEventConfigurationTable',row,col,...
            num2str(eventData(index).Name));
            return;
        end

        for ii=1:length(eventData)
            if strcmp(eventData(ii).Name,val)
                errordlg(DAStudio.message('RTW:autosar:internalBehavShortNameClash',...
                val),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                dlg.setTableItemValue('AutosarEventConfigurationTable',row,col,...
                num2str(eventData(index).Name));
                return;
            end
        end
        isValid=autosar.ui.utils.checkDuplicateInSequence(m3iObj.containerM3I.Events,val);
        if~isValid
            errMsg=DAStudio.message('RTW:autosar:internalBehavShortNameClash',val);
            errordlg(errMsg,...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            return;
        end

        eventData(index).setName(val);
    otherwise
        assert(false,'Should not be here');
    end
    arExplorer.EventData=eventData;
end

function value=i_comboBoxEntryToValue(entries,entry)


    idx=find(strcmp(entry,entries));
    value=0;
    if~isempty(idx)
        value=idx-1;
    end
end



