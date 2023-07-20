





function modeReceiverPortChanged(dlg,~)

    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    mapping=arExplorer.MappingManager.getActiveMappingFor('AutosarTarget');
    assert(isa(m3iObj,'Simulink.metamodel.arplatform.behavior.Runnable'));
    aSWC=m3iObj.containerM3I.containerM3I;
    row=dlg.getSelectedTableRow('AutosarEventConfigurationTable');
    index=autosar.ui.utils.getEventIndex(eventData,row,m3iObj.Name);
    assert(strcmp(eventData(index).EventType,autosar.ui.wizard.PackageString.EventTypes{3}));
    val=dlg.getWidgetValue('AutosarModeReceiverPort');
    modeReceiverPort=i_comboBoxValueToEntry(eventData(index).ModeReceiverPortCellValues,val);
    eventData(index).setModeReceiverPort(modeReceiverPort);

    modeDeclarationsCell=cell(1,1);
    modeDeclarationsCell{1}=DAStudio.message('RTW:autosar:selectERstr');

    for ii=1:length(mapping.Inports)
        if strcmp(mapping.Inports(ii).MappedTo.DataAccessMode,'ModeReceive')&&...
            strcmp(mapping.Inports(ii).MappedTo.Port,modeReceiverPort)
            blkHdl=get_param(mapping.Inports(ii).Block,'Handle');
            dataType=get_param(blkHdl,'OutDataTypeStr');
            dataType=autosar.utils.StripPrefix(dataType);
            [~,literalStrings]=enumeration(dataType);
            for jj=1:length(literalStrings)
                modeDeclarationsCell{end+1}=literalStrings{jj};%#ok<AGROW>
            end
            break;
        end
    end


    if numel(modeDeclarationsCell)==1

        for ii=1:aSWC.ModeReceiverPorts.size()
            if strcmp(modeReceiverPort,aSWC.ModeReceiverPorts.at(ii).Name)
                modeGroup=aSWC.ModeReceiverPorts.at(ii).Interface.ModeGroup;
                if~isempty(modeGroup)&&~isempty(modeGroup.ModeGroup)
                    for jj=1:modeGroup.ModeGroup.Mode.size()
                        modeDeclarationsCell{end+1}=modeGroup.ModeGroup.Mode.at(jj).Name;%#ok<AGROW>
                    end
                end
                break;
            end
        end



        for ii=1:aSWC.ReceiverPorts.size()
            rPort=aSWC.ReceiverPorts.at(ii);
            if strcmp(modeReceiverPort,rPort.Name)&&~isempty(rPort.Interface)
                modeGroup=rPort.Interface.ModeGroup;
                if modeGroup.size()>0
                    mdg=modeGroup.at(1).ModeGroup;
                    if~isempty(mdg)
                        for jj=1:mdg.Mode.size()
                            modeDeclarationsCell{end+1}=mdg.Mode.at(jj).Name;%#ok<AGROW>
                        end
                    end
                end
                break;
            end
        end
    end

    eventName=dlg.getTableItemValue('AutosarEventConfigurationTable',row,1);

    for idx=1:length(eventData)
        if strcmp(eventData(idx).Name,eventName)
            eventData(index).setModeDeclarationCellValues1(modeDeclarationsCell);
            eventData(index).setModeDeclaration1(modeDeclarationsCell{1});
            eventData(index).setModeDeclarationCellValues2(modeDeclarationsCell);
            eventData(index).setModeDeclaration2(modeDeclarationsCell{1});
            break;
        end
    end
    arExplorer.EventData=eventData;
    arExplorer.SelectedEventName=eventData(index).Name;
    dlg.refresh;
end

function entry=i_comboBoxValueToEntry(entries,value)

    entry=entries{value+1};
end


