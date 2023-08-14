classdef FiMMatrixSpreadsheet<autosar.ui.bsw.Spreadsheet





    methods
        function obj=FiMMatrixSpreadsheet(dlgSource)
            obj=obj@autosar.ui.bsw.Spreadsheet(dlgSource,'m_InhibitionMatrix');
        end
    end

    methods(Access=protected)
        function aChildren=loadChildrenImpl(this,blkH)
            mappingChildren=this.getMappingSpreadsheetRows();

            portDefinedArgs=arrayfun(@(x)x.ClientPort.PortDefinedArgument,mappingChildren,'UniformOutput',false);

            idTypes=arrayfun(@(x)x.ClientPort.IdType,mappingChildren,'UniformOutput',false);


            masksParam=get_param(blkH,'InhibitionMatrix');
            masks=eval(masksParam);



            [maskFids,eventIds]=find(masks);

            if~isempty(maskFids)
                maskFids=maskFids-1;
            end

            fidEntries=strcmp('FID',idTypes);
            fidEntryArgs=unique(portDefinedArgs(fidEntries));
            numFids=numel(fidEntryArgs);
            aChildren=autosar.ui.bsw.FiMMatrixSpreadsheetRow.empty(numFids,0);

            fidToRowIndex=containers.Map;






            for resultIndex=1:length(fidEntryArgs)

                fid=str2double(fidEntryArgs(resultIndex));
                fidChar=fidEntryArgs{resultIndex};


                maskFidIndex=find(maskFids==fid);
                if(maskFidIndex)
                    if~(fidToRowIndex.isKey(fidChar))
                        newRow=autosar.ui.bsw.FiMMatrixSpreadsheetRow(this.DlgSource,fidChar);

                        matchingEventIds=eventIds(maskFidIndex);
                        maskValues=masks(fid+1,eventIds(maskFidIndex));
                        maskValuesStr=arrayfun(@(x)autosar.ui.bsw.FidMask.valToString(x),maskValues,'UniformOutput',false);

                        for ii=1:numel(maskValuesStr)

                            fidMask=autosar.ui.bsw.FidMask(fidChar);
                            fidMask.setEventId(num2str(matchingEventIds(ii)));
                            fidMask.setMask(maskValuesStr{ii});

                            subRow=autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow(this.DlgSource,newRow,fidMask);
                            newRow.addHierarchicalChild(subRow);
                        end



                        aChildren(resultIndex)=newRow;

                        fidToRowIndex(fidChar)=resultIndex;
                    end
                else
                    if~fidToRowIndex.isKey(fidChar)
                        aChildren(resultIndex)=...
                        autosar.ui.bsw.FiMMatrixSpreadsheetRow(this.DlgSource,fidChar);

                        fidToRowIndex(fidChar)=resultIndex;
                    end
                end
            end
        end

        function clearUnusedValues(~,blkH)


            portDefinedArgs=eval(get_param(blkH,'ClientPortPortDefinedArguments'));
            masksParam=get_param(blkH,'InhibitionMatrix');


            masks=eval(masksParam);


            idTypes=eval(get_param(blkH,'IdTypes'));

            if numel(idTypes)~=numel(portDefinedArgs)


                return;
            end



            [~,eventIds]=find(masks);



            eventEntries=strcmp('EventId',idTypes);
            eventEntryArgs=unique(portDefinedArgs(eventEntries));
            eventEntryIds=cellfun(@(x)str2double(x),eventEntryArgs);
            unusedEventIdMasks=setdiff(eventIds,eventEntryIds);



            masks(:,unusedEventIdMasks)=0;

            set_param(blkH,'InhibitionMatrix',mat2str(masks));
        end
    end

    methods(Static)
        function addInhibitionCondition(dialog)


            fimSpreadsheet=dialog.getWidgetInterface('fimTagmatrixSpreadsheet');
            selectedRow=fimSpreadsheet.getSelection;

            if isempty(selectedRow)
                return;
            end

            if iscell(selectedRow)

                selectedRow=selectedRow{1};
            end

            if isa(selectedRow,'autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow')
                selectedRow=selectedRow.Parent;
            elseif isa(selectedRow,'autosar.ui.bsw.FiMMatrixSpreadsheetRow')

            else

                return;
            end


            mappingChildren=dialog.getDialogSource().UserData.m_MappingChildren;
            eventIdPorts=arrayfun(@(x)strcmp(x.IdType,'EventId'),[mappingChildren.ClientPort]);
            eventIds=arrayfun(@(x)str2double(x.PortDefinedArgument),[mappingChildren(eventIdPorts).ClientPort]);
            firstEventId=num2str(min(eventIds));

            rowFid=selectedRow.FID;
            fidMask=autosar.ui.bsw.FidMask(rowFid);
            fidMask.setEventId(firstEventId);
            fidMask.setMask('LAST_FAILED');
            selectedRow.addInhibitionCondition(fidMask);

            fimSpreadsheet.update();
            dialog.enableApplyButton(true);
        end

        function removeInhibitionCondition(dialog)


            function removeInnerRow(row)
                if~isa(row,'autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow')

                    return;
                end

                row.Parent.removeChild(row);
            end

            fimSpreadsheet=dialog.getWidgetInterface('fimTagmatrixSpreadsheet');
            selectedRow=fimSpreadsheet.getSelection;

            if isempty(selectedRow)
                return;
            end

            if iscell(selectedRow)

                cellfun(@(x)removeInnerRow(x),selectedRow);
            else
                removeInnerRow(selectedRow)
            end

            fimSpreadsheet.update();
            dialog.enableApplyButton(true);
        end

        function isEnabled=isAddButtonEnabled(dialog)
            blkH=dialog.getBlock().Handle;
            isEnabled=autosar.ui.bsw.FiMMatrixSpreadsheet.hasFimPorts(blkH)...
            &&autosar.ui.bsw.FiMMatrixSpreadsheet.hasEventPorts(blkH);
        end

        function isEnabled=isRemoveButtonEnabled(dialog)
            blkH=dialog.getBlock().Handle;
            isEnabled=autosar.ui.bsw.FiMMatrixSpreadsheet.hasFimPorts(blkH)...
            &&autosar.ui.bsw.FiMMatrixSpreadsheet.hasEventPorts(blkH);
        end
    end

    methods(Static,Access=private)
        function hasFimPorts=hasFimPorts(blkH)
            idTypes=eval(get_param(blkH,'IdTypes'));
            fidEntries=strcmp('FID',idTypes);
            hasFimPorts=sum(fidEntries)>0;
        end

        function hasEventPorts=hasEventPorts(blkH)
            idTypes=eval(get_param(blkH,'IdTypes'));
            eventEntries=strcmp('EventId',idTypes);
            hasEventPorts=sum(eventEntries)>0;
        end
    end
end



