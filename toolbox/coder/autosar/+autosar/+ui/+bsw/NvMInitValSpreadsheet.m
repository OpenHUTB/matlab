classdef NvMInitValSpreadsheet<autosar.ui.bsw.Spreadsheet




    methods
        function obj=NvMInitValSpreadsheet(dlgSource)
            obj=obj@autosar.ui.bsw.Spreadsheet(dlgSource,'m_InitValues');
        end
    end

    methods(Access=protected)
        function aChildren=loadChildrenImpl(this,blkH)
            mappingChildren=this.getMappingSpreadsheetRows();

            portDefinedArgs=arrayfun(@(x)x.ClientPort.PortDefinedArgument,mappingChildren,'UniformOutput',false);


            initValuesParam=get_param(blkH,'NvInitValues');
            initialValues=eval(initValuesParam);

            nvBlockEntryArgs=unique(portDefinedArgs);
            numNvBlocks=numel(nvBlockEntryArgs);
            aChildren=autosar.ui.bsw.NvMInitValSpreadsheetRow.empty(numNvBlocks,0);

            nvBlockToRowIndex=containers.Map;






            for resultIndex=1:numel(nvBlockEntryArgs)

                nvBlockId=str2double(nvBlockEntryArgs(resultIndex));
                nvBlockIdChar=nvBlockEntryArgs{resultIndex};

                if nvBlockToRowIndex.isKey(nvBlockIdChar)

                    continue;
                end

                newRow=autosar.ui.bsw.NvMInitValSpreadsheetRow(this.DlgSource,nvBlockIdChar);


                if nvBlockId<=numel(initialValues)
                    newRow.setInitVal(initialValues{nvBlockId});
                end

                aChildren(resultIndex)=newRow;

                nvBlockToRowIndex(nvBlockIdChar)=resultIndex;
            end
        end

        function clearUnusedValues(~,blkH)
            portDefinedArgs=eval(get_param(blkH,'ClientPortPortDefinedArguments'));

            masksParam=get_param(blkH,'NvInitValues');


            initialValues=eval(masksParam);

            idTypes=eval(get_param(blkH,'IdTypes'));
            if numel(idTypes)~=numel(portDefinedArgs)


                return;
            end

            assert(isempty(idTypes)||all(strcmp(idTypes,'BlockId')),'Expect only NVRAM Blocks');
            usedIds=cellfun(@(x)str2double(x),portDefinedArgs);
            serializedIds=1:numel(initialValues);
            unusedIds=setdiff(serializedIds,usedIds);
            initialValues(unusedIds)={'0'};


            initialValues=cellfun(@(x)replace(x,"'","''"),initialValues,'UniformOutput',false);

            set_param(blkH,'NvInitValues',['{',autosar.api.Utils.cell2str(initialValues),'}']);
        end
    end

end


