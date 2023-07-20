function[status,errmsg]=PreApplyCallback(~,dialogH)








    try
        source=dialogH.getDialogSource();
        blockH=source.getBlock();
        source.UserData.duringPreApply=true;
        [status,errmsg]=loc_doPreApply(blockH,source,dialogH);
        source.UserData.duringPreApply=false;
    catch E


        source.UserData.duringPreApply=false;
        throwAsCaller(E);
    end
end


function[status,errmsg]=loc_doPreApply(block,source,dlg)
    if~block.isHierarchyReadonly
        switch block.MaskType
        case autosar.bsw.ServiceComponent.DemServiceBlockMaskType
            savePortNamesAndIdsToBlock(source,block);
            saveMaxIdsToBlock(block);
            saveFimTableToBlock(source,block);
            saveFaults(source,block);
        case autosar.bsw.ServiceComponent.NvMServiceBlockMaskType
            savePortNamesAndIdsToBlock(source,block);
            saveNVRAMInitialValuesToBlock(source,block);
        otherwise
            assert(false,'Unexpected block type');
        end
    end

    [status,errmsg]=source.preApplyCallback(dlg);
end

function savePortNamesAndIdsToBlock(source,block)
    if isempty(source.UserData.m_MappingChildren)

        return;
    end

    clientPortData=[source.UserData.m_MappingChildren(:).ClientPort];

    clientPortNames={clientPortData(:).Name};
    portDefinedArguments={clientPortData(:).PortDefinedArgument};


    block.ClientPortNames=['{',autosar.api.Utils.cell2str(clientPortNames),'}'];
    block.ClientPortPortDefinedArguments=['{',autosar.api.Utils.cell2str(portDefinedArguments),'}'];
end

function saveMaxIdsToBlock(block)

    portDefinedArguments=eval(block.ClientPortPortDefinedArguments);


    idTypes=eval(block.IdTypes);
    if isempty(idTypes)&&(numel(idTypes)<numel(portDefinedArguments))
        DAStudio.error('autosarstandard:bsw:DscRequiresUpdate');
    end

    maxEventId=0;
    maxFid=0;
    for ii=1:length(portDefinedArguments)
        id=str2double(portDefinedArguments(ii));

        if strcmp(idTypes(ii),'EventId')&&id>maxEventId
            maxEventId=id;
        else
            if strcmp(idTypes(ii),'FID')&&id>maxFid
                maxFid=id;
            end
        end
    end


    maxEventId=max(maxEventId,2);
    maxFid=max(maxFid,1);
    maxId=max(maxEventId,maxFid);

    if maxId>intmax('uint16')
        DAStudio.error('autosarstandard:bsw:IdOutOfRange');
    end


    block.MaxEventId=num2str(maxEventId);
    block.MaxFID=num2str(maxFid);
end

function saveFimTableToBlock(source,block)
    if isempty(source.UserData.m_InhibitionMatrix)

        return;
    end

    maxEventId=eval(block.MaxEventId);
    maxFid=eval(block.MaxFID);

    tableData=zeros(maxFid+1,maxEventId,'uint8');

    fidGroups=[source.UserData.m_InhibitionMatrix(:)];

    for groupIndex=1:length(fidGroups)
        fidGroup=fidGroups(groupIndex);
        fidForEntry=str2double(fidGroup.FID);

        children=fidGroup.Children;
        for childIdx=1:numel(children)
            child=children(childIdx);
            childEventId=str2double(child.FidMask.EventId);
            maskValue=autosar.ui.bsw.FidMask.stringToVal(child.FidMask.Mask);
            tableData(fidForEntry+1,childEventId)=uint8(maskValue);
        end
    end


    block.InhibitionMatrix=mat2str(tableData);
end

function saveNVRAMInitialValuesToBlock(source,block)
    if~slfeature('NVRAMInitialValue')
        return;
    end

    if isempty(source.UserData.m_InitValues)

        return;
    end

    initialValues=cell(1,eval(block.MaxBlockId));

    for ii=1:numel(source.UserData.m_InitValues)
        initValueDefinition=source.UserData.m_InitValues(ii);
        initValStr=initValueDefinition.InitValStr;
        initValStr=replace(initValStr,"'","''");
        initialValues{eval(initValueDefinition.BlockId)}=initValStr;
    end


    portDefinedArgs=eval(block.ClientPortPortDefinedArguments);
    utilizedPorts=unique(str2double(portDefinedArgs));
    for ii=1:numel(initialValues)
        if~any(utilizedPorts==ii)
            initialValues{ii}='0';
        end
    end

    block.NvInitValues=['{',autosar.api.Utils.cell2str(initialValues),'}'];
end

function saveFaults(source,block)
    if~slfeature('FaultAnalyzerBsw')
        return;
    end

    if isempty(source.UserData.m_EventMatrix)

        return;
    end


    faultInjector=autosar.bsw.rte.FaultInjector.getFaultInjector(block.Handle);
    slEventFaults=faultInjector.getEventFaults();



    uiFaultedEventIds=[source.UserData.m_EventMatrix(:)];
    for faultedEventIndex=1:length(uiFaultedEventIds)
        uifaultedEventId=uiFaultedEventIds(faultedEventIndex);



        children=uifaultedEventId.Children;
        if isempty(children)

            uiFaults=autosar.ui.bsw.Fault.empty;
        else
            uiFaults=[children.Fault];
        end



        eventIdStr=uifaultedEventId.EventId;
        if~slEventFaults.isKey(eventIdStr)

            existingSlFaultsForEventId=Simulink.fault.Fault.empty;
            existingSlFaultNamesForEventId={};
        else
            existingSlFaultsForEventId=slEventFaults(eventIdStr);
            existingSlFaultNamesForEventId={existingSlFaultsForEventId.Name};
        end


        for ii=1:numel(uiFaults)
            uiFault=uiFaults(ii);
            matchingExistingFaults=strcmp(uiFault.FaultName,existingSlFaultNamesForEventId);
            alreadyExists=any(matchingExistingFaults);
            if alreadyExists
                slFault=existingSlFaultsForEventId(matchingExistingFaults);
                faultBlock=autosar.bsw.rte.FaultInjector.findFaultBlkInFaultMdl(slFault);
                switch uiFault.FaultType
                case 'Override'
                    expectedFaultBlock=find_system(faultBlock,'MaskType','DemFaultOverride');
                case 'Inject'
                    expectedFaultBlock=find_system(faultBlock,'MaskType','DemFaultInject');
                otherwise



                    continue;
                end
                needsCreation=isempty(expectedFaultBlock);
            else
                needsCreation=true;
            end

            if needsCreation
                if alreadyExists
                    faultInjector.removeFault(slFault);
                end
                slFault=faultInjector.addFault(eventIdStr,uiFault.FaultName,uiFault.FaultType);
                faultBlock=autosar.bsw.rte.FaultInjector.findFaultBlkInFaultMdl(slFault);
                switch uiFault.FaultType
                case 'Override'
                    expectedFaultBlock=find_system(faultBlock,'MaskType','DemFaultOverride');
                case 'Inject'
                    expectedFaultBlock=find_system(faultBlock,'MaskType','DemFaultInject');
                otherwise
                    assert(false,'Block should be created');
                end
            end


            slFault.TriggerType=uiFault.triggerTypeOptions{uiFault.TriggerType+1};
            if strcmp(slFault.TriggerType,'Timed')
                slFault.StartTime=str2double(uiFault.StartTime);
            end

            assert(~isempty(expectedFaultBlock),'Expected to have a fault block to update');
            expectedFaultBlock=expectedFaultBlock{1};
            switch uiFault.FaultType
            case 'Override'
                set_param(expectedFaultBlock,'TF_Value',getUiSettingForUdsBit(1,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'TFTOC_Value',getUiSettingForUdsBit(2,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'PDTC_Value',getUiSettingForUdsBit(3,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'CDTC_Value',getUiSettingForUdsBit(4,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'TNCSLC_Value',getUiSettingForUdsBit(5,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'TFSLC_Value',getUiSettingForUdsBit(6,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'TNCTOC_Value',getUiSettingForUdsBit(7,uiFault.OverrideSetting));
                set_param(expectedFaultBlock,'WIR_Value',getUiSettingForUdsBit(8,uiFault.OverrideSetting));
            case 'Inject'
                faultOptions=autosar.ui.bsw.FaultSpreadsheet.faultInjectOptions;
                injectIdx=uiFault.InjectSetting+1;
                set_param(expectedFaultBlock,'FaultType',faultOptions{injectIdx});
            otherwise
                assert(false,'Cannot configure fault');
            end
        end


        expectedFaults=arrayfun(@(x)x.FaultName,uiFaults,'UniformOutput',false);
        [~,idx]=setdiff(existingSlFaultNamesForEventId,expectedFaults);
        faultsToRemove=existingSlFaultsForEventId(idx);
        arrayfun(@(x)faultInjector.removeFault(x),faultsToRemove);
    end

    faultInjector.clearUnfaultedEvents();
end

function uiValue=getUiSettingForUdsBit(udsBit,udsByte)


    if bitget(udsByte,udsBit)
        uiValue='on';
    else
        uiValue='off';
    end
end



