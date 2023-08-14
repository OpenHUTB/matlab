classdef FaultSpreadsheet<autosar.ui.bsw.Spreadsheet





    properties(Constant)
        faultInjectOptions={
'Event Fail'
'Event Pass'
'Operation Cycle Start'
'Operation Cycle End'
'Fault Record Overwritten'
'Fault Maturation'
'Clear Diagnostic'
'Aging'
'Healing'
        'Indicator Conditions Met'};
    end

    methods
        function obj=FaultSpreadsheet(dlgSource)
            obj=obj@autosar.ui.bsw.Spreadsheet(dlgSource,'m_EventMatrix');
        end
    end

    methods(Access=protected)
        function aChildren=loadChildrenImpl(this,blkH)
            mappingChildren=this.getMappingSpreadsheetRows();

            portDefinedArgs=arrayfun(@(x)x.ClientPort.PortDefinedArgument,mappingChildren,'UniformOutput',false);

            idTypes=arrayfun(@(x)x.ClientPort.IdType,mappingChildren,'UniformOutput',false);


            eventEntries=strcmp('EventId',idTypes);
            eventEntryArgs=unique(portDefinedArgs(eventEntries));
            numEvents=numel(eventEntryArgs);
            aChildren=autosar.ui.bsw.FaultSpreadsheetRow.empty(numEvents,0);

            eventToRowIndex=containers.Map;






            faultInjector=autosar.bsw.rte.FaultInjector.getFaultInjector(blkH);
            eventFaults=faultInjector.getEventFaults();

            for resultIndex=1:length(eventEntryArgs)
                eventIdChar=eventEntryArgs{resultIndex};


                if eventFaults.isKey(eventIdChar)
                    if~eventToRowIndex.isKey(eventIdChar)
                        newRow=autosar.ui.bsw.FaultSpreadsheetRow(this.DlgSource,eventIdChar);


                        faultsForThisEventId=eventFaults(eventIdChar);

                        for ii=1:numel(faultsForThisEventId)
                            uiFault=autosar.ui.bsw.Fault.create(faultsForThisEventId(ii));

                            subRow=autosar.ui.bsw.FaultSpreadsheetInnerRow(this.DlgSource,newRow,uiFault);
                            newRow.addHierarchicalChild(subRow);
                        end

                        aChildren(resultIndex)=newRow;

                        eventToRowIndex(eventIdChar)=resultIndex;
                    end
                else
                    if~eventToRowIndex.isKey(eventIdChar)
                        aChildren(resultIndex)=...
                        autosar.ui.bsw.FaultSpreadsheetRow(this.DlgSource,eventIdChar);

                        eventToRowIndex(eventIdChar)=resultIndex;
                    end
                end
            end
        end

        function clearUnusedValues(~,blkH)


            portDefinedArgs=eval(get_param(blkH,'ClientPortPortDefinedArguments'));


            idTypes=eval(get_param(blkH,'IdTypes'));

            if numel(idTypes)~=numel(portDefinedArgs)


                return;
            end



            eventEntries=strcmp('EventId',idTypes);
            eventEntryArgs=unique(portDefinedArgs(eventEntries));

            faultInjector=autosar.bsw.rte.FaultInjector.getFaultInjector(blkH);
            eventFaults=faultInjector.getEventFaults();

            if~isempty(eventFaults.keys)
                unusedEventIdMasks=setdiff(eventFaults.keys,eventEntryArgs);

                for ii=1:numel(unusedEventIdMasks)
                    faultInjector.clearEventFaults(unusedEventIdMasks{ii});
                end
            end
        end
    end

    methods(Static)
        function onItemClicked(d,r,c,name)


            dialogElemTag=d;
            sourceObjs=r;
            column=c;%#ok<NASGU>
            dialog=name;

            if~strcmp(dialogElemTag,'faultTagfaultSpreadsheet')
                return;
            end
            if isa(sourceObjs{1},'autosar.ui.bsw.FaultSpreadsheetInnerRow')
                innerRow=sourceObjs{1};
                uiFault=innerRow.Fault;
                dialog.setWidgetValue('faultTagfaultLookup',uiFault.InjectSetting);
                dialog.setWidgetValue('faultTagtfCheck',bitget(uiFault.OverrideSetting,1));
                dialog.setWidgetValue('faultTagtftocCheck',bitget(uiFault.OverrideSetting,2));
                dialog.setWidgetValue('faultTagpdtcCheck',bitget(uiFault.OverrideSetting,3));
                dialog.setWidgetValue('faultTagcdtcCheck',bitget(uiFault.OverrideSetting,4));
                dialog.setWidgetValue('faultTagtncslcCheck',bitget(uiFault.OverrideSetting,5));
                dialog.setWidgetValue('faultTagtfslcCheck',bitget(uiFault.OverrideSetting,6));
                dialog.setWidgetValue('faultTagtnctocCheck',bitget(uiFault.OverrideSetting,7));
                dialog.setWidgetValue('faultTagwirCheck',bitget(uiFault.OverrideSetting,8));

                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultHelp');
                autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultTriggerLookup');
                autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultTriggerStartTime');

                dialog.setWidgetValue('faultTagfaultTriggerLookup',uiFault.TriggerType);
                dialog.setWidgetValue('faultTagfaultTriggerStartTime',uiFault.StartTime);
                autosar.ui.bsw.FaultSpreadsheet.setFaultTriggerType(dialog,uiFault.TriggerType);
                switch uiFault.FaultType
                case 'Override'
                    autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultOverrideContainer');
                    autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultLookup');
                case 'Inject'
                    autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultOverrideContainer');
                    autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultLookup');
                otherwise
                    assert(false,'Invalid fault type')
                end
            else
                autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultHelp');
                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultTriggerLookup');
                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultTriggerStartTime');
                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultLookup');
                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultOverrideContainer');
            end

        end

        function addFault(dialog)
            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRow=faultSpreadsheet.getSelection;

            if isempty(selectedRow)
                return;
            end

            if iscell(selectedRow)

                selectedRow=selectedRow{1};
            end

            if isa(selectedRow,'autosar.ui.bsw.FaultSpreadsheetInnerRow')
                selectedRow=selectedRow.Parent;
            elseif isa(selectedRow,'autosar.ui.bsw.FaultSpreadsheetRow')

            else

                return;
            end

            faultName=selectedRow.getNewFaultName();
            selectedRow.addFault(faultName);

            faultSpreadsheet.update();
            dialog.enableApplyButton(true);
        end

        function removeFault(dialog)
            function removeInnerRow(row)
                if~isa(row,'autosar.ui.bsw.FaultSpreadsheetInnerRow')

                    return;
                end

                row.Parent.removeChild(row);
            end

            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRow=faultSpreadsheet.getSelection;

            if isempty(selectedRow)
                return;
            end

            if iscell(selectedRow)

                cellfun(@(x)removeInnerRow(x),selectedRow);
            else
                removeInnerRow(selectedRow)
            end

            faultSpreadsheet.update();
            dialog.enableApplyButton(true);
        end

        function isEnabled=isAddButtonEnabled(dialog)
            blkH=dialog.getBlock().Handle;
            isEnabled=autosar.ui.bsw.FaultSpreadsheet.hasEventPorts(blkH);
        end

        function isEnabled=isRemoveButtonEnabled(dialog)
            blkH=dialog.getBlock().Handle;
            isEnabled=autosar.ui.bsw.FaultSpreadsheet.hasEventPorts(blkH);
        end

        function setFaultInjectType(dialog,value)
            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRows=faultSpreadsheet.getSelection;

            if isempty(selectedRows)
                return;
            end

            for ii=1:numel(selectedRows)
                selectedRows{ii}.Fault.InjectSetting=value;
            end
        end

        function setFaultOverrideBit(dialog,bit,value)
            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRows=faultSpreadsheet.getSelection;

            if isempty(selectedRows)
                return;
            end

            for ii=1:numel(selectedRows)
                selectedRows{ii}.Fault.OverrideSetting=...
                bitset(selectedRows{ii}.Fault.OverrideSetting,bit,value);
            end
        end

        function setFaultTriggerType(dialog,value)
            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRows=faultSpreadsheet.getSelection;

            if isempty(selectedRows)
                return;
            end

            for ii=1:numel(selectedRows)
                selectedRows{ii}.Fault.TriggerType=value;
            end

            switch(value)
            case 1
                autosar.ui.bsw.SpreadsheetBase.enableWidget(dialog,'faultTagfaultTriggerStartTime');
            otherwise
                autosar.ui.bsw.SpreadsheetBase.disableWidget(dialog,'faultTagfaultTriggerStartTime');
            end
        end

        function setFaultStartTime(dialog,value)
            faultSpreadsheet=dialog.getWidgetInterface('faultTagfaultSpreadsheet');
            selectedRows=faultSpreadsheet.getSelection;

            if isempty(selectedRows)
                return;
            end

            for ii=1:numel(selectedRows)
                selectedRows{ii}.Fault.StartTime=value;
            end
        end
    end

    methods(Static,Access=private)
        function hasEventPorts=hasEventPorts(blkH)
            idTypes=eval(get_param(blkH,'IdTypes'));
            eventEntries=strcmp('EventId',idTypes);
            hasEventPorts=sum(eventEntries)>0;
        end
    end
end




