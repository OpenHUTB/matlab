function updateSubSystemForGivenScenario(blockPath,dataModel)









    current_port_handles=find_system(blockPath,'findall','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'Parent',blockPath,...
    'BlockType','Outport');

    signals=dataModel.getSignalsForScenario(get_param(blockPath,'ActiveScenario'));

    if length(unique(signals))~=length(signals)
        msg=MSLException(getSimulinkBlockHandle(blockPath),message('sl_sta_editor_block:message:DuplicateSignalsNotSupported'));
        dig=MSLDiagnostic(msg);
        dig.reportAsError(bdroot(block),false);
        return;
    end

    Simulink.signaleditorblock.MaskSetting.disableMaskInitialization(blockPath);
    elementNames=signals;
    signalNames=cell(length(current_port_handles),1);
    for id=1:length(signalNames)
        signalNames{id}=...
        Simulink.signaleditorblock.getSignalNameFromPortHandle(current_port_handles(id));
    end
    names_to_add=elementNames;
    port_index=[];
    if ischar(signalNames)
        signalNames={signalNames};
    end
    port_number_to_handles=zeros(length(signalNames),2);
    port_ids_repurposed=zeros(length(signalNames),1);
    port_repurposed_count=0;
    for id=1:length(signalNames)
        if(iscell(elementNames)&&~isempty(elementNames))
            port_index=find(ismember(elementNames,signalNames{id}));
        end
        if~isempty(port_index)
            port_repurposed_count=port_repurposed_count+1;
            port_number_to_handles(port_repurposed_count,1)=port_index;
            port_number_to_handles(port_repurposed_count,2)=current_port_handles(id);
            port_ids_repurposed(port_repurposed_count)=id;




            outBlock=current_port_handles(id);
            PortConnectivity=get_param(outBlock,'PortConnectivity');
            fromWsBlock=PortConnectivity.SrcBlock;
            portHandles=get_param(fromWsBlock,'PortHandles');
            line=get_param(portHandles.Outport,'Line');
            if strcmp(get_param(blockPath,'PreserveSignalName'),'on')
                sigName=names_to_add{port_index};
            else
                sigName='';
            end
            set_param(line,'Name',sigName);



            names_to_add{port_index}=[];
        end
    end
    port_number_to_handles=port_number_to_handles(1:port_repurposed_count,:);
    port_ids_repurposed=port_ids_repurposed(1:port_repurposed_count,:);
    port_number_to_handles=sortrows(port_number_to_handles,'descend');
    for portNum=1:size(port_number_to_handles,1)
        set_param(port_number_to_handles(portNum,2),'Port',num2str(port_number_to_handles(portNum,1)));
    end
    names_to_add=names_to_add(~cellfun('isempty',names_to_add));

    current_port_handles(port_ids_repurposed)=[];
    port_id_count=1;
    port_ids_repurposed=[];
    for id=1:length(names_to_add)
        if length(current_port_handles)>=port_id_count
            outBlock=current_port_handles(port_id_count);
            port_ids_repurposed(end+1)=port_id_count;
            port_id_count=port_id_count+1;
            PortConnectivity=get_param(outBlock,'PortConnectivity');
            fromWsBlock=PortConnectivity.SrcBlock;
            set_param(fromWsBlock,'Tag',['wks_',names_to_add{id}]);
            set_param(outBlock,'Tag',['out_',names_to_add{id}]);
            portHandles=get_param(fromWsBlock,'PortHandles');
            line=get_param(portHandles.Outport,'Line');
            if strcmp(get_param(blockPath,'PreserveSignalName'),'on')
                sigName=names_to_add{id};
            else
                sigName='';
            end
            set_param(line,'Name',sigName);
        else

            dsElementName=names_to_add{id};
            fromWsBlock=[blockPath,'/','From Workspace'];
            outBlock=[blockPath,'/','Out'];
            fromWsBlockH=add_block('built-in/FromWorkspace',fromWsBlock,'MakeNameUnique','on','Tag',['wks_',dsElementName]);
            outBlockH=add_block('built-in/Outport',outBlock,'MakeNameUnique','on','Tag',['out_',dsElementName]);
            fromWsBlockPortHandles=get_param(fromWsBlockH,'PortHandles');
            outBlockPortHandles=get_param(outBlockH,'PortHandles');
            lineH=add_line(blockPath,fromWsBlockPortHandles.Outport(1),outBlockPortHandles.Inport(1));
            if strcmp(get_param(blockPath,'PreserveSignalName'),'on')
                sigName=dsElementName;
            else
                sigName='';
            end
            set_param(lineH,'Name',sigName);
        end
    end
    current_port_handles(port_ids_repurposed)=[];

    for id=1:length(current_port_handles)

        deleteBlocks(current_port_handles(id));
    end
    Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(blockPath);
end


function deleteBlocks(blockH)
    PortConnectivity=get_param(blockH,'PortConnectivity');
    fromWsBlock=PortConnectivity.SrcBlock;
    lineH=get_param(blockH,'LineHandles');
    delete_line(lineH.Inport(1));
    delete_block([blockH,fromWsBlock]);
end

