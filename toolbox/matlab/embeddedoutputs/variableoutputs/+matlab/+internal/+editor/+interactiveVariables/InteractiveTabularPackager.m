classdef InteractiveTabularPackager







    methods(Static)
        function[outputType,outputData]=packageVarTabularOutput(variableName,variableValue,...
            header,editorId,isPreview,requestId)

            import matlab.internal.editor.interactiveVariables.*;
            import matlab.internal.editor.VariableUtilities;
            import matlab.internal.editor.VariableOutputPackager;



            valueString='';
            truncationInfo='';
            if nargin<5||(nargin>4&&~isPreview)
                [valueString,truncationInfo]=InteractiveTabularUtils.getTruncatedStringFromTable(variableName,...
                variableValue,header,InteractiveTablesPackager.ROW_TRUNCATION_LIMIT);
            end



            isMaxOutputs=InteractiveVariablesPackager.isMaxInteractiveOutputs(editorId,requestId)&&~isPreview;
            if isMaxOutputs
                [outputType,outputData]=InteractiveTabularUtils.createLegacyOutput(variableName,valueString,header,truncationInfo);
            else
                docID=InteractiveTabularUtils.createVariableView(editorId,variableName,variableValue,isPreview,requestId);

                originalSize=size(variableValue);
                originalValue=variableValue;

                veAttributes=internal.matlab.variableeditor.VEDataAttributes(originalValue);
                [~,validAttributes]=internal.matlab.datatoolsservices.WidgetRegistry.getDataAttributes(veAttributes,originalSize);

                isStruct=isstruct(variableValue);
                isObject=isobject(variableValue)||all(all(ishandle(variableValue)))||(isStruct&&~veAttributes.isRowOrColumnVector);
                isCell=iscell(variableValue);
                tabularType=struct('isStruct',isStruct,'isObject',isObject,'isCell',isCell);

                if(isStruct&&~isObject)
                    variableValue=internal.matlab.datatoolsservices.FormatDataUtils.convertStructToCell(originalValue);
                end
                variableSize=size(variableValue);
                partialRows=min(InteractiveTablesPackager.MAX_ROWS_TABLES,variableSize(1));
                partialColumns=min(InteractiveTabularUtils.MAX_COLS_PAGE_SIZE,variableSize(2));

                totalRows=variableSize(1);
                totalColumns=variableSize(2);
                try
                    partialValue=variableValue(1:partialRows,1:partialColumns);
                catch


                    [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,variableValue,header);
                    return;
                end
                [prepopulatedData,data]=InteractiveTabularPackager.getPrepopulatedData(tabularType,partialValue,originalValue,partialRows,partialColumns,isPreview);



                cellMetaData=InteractiveTabularPackager.getCellMetaData(tabularType,partialValue,originalValue,partialRows,partialColumns);
                columnMetaData=InteractiveTabularPackager.getColumnMetaData(tabularType,partialValue,originalValue,partialColumns,data);
                tableMetaData=InteractiveTabularPackager.getTableMetaData(tabularType,partialValue,originalValue);
                rowMetaData=InteractiveTabularPackager.getRowMetaData(tabularType,partialValue,originalValue,partialRows);

                prepopulatedMetaData=struct;
                prepopulatedMetaData.RowMetaData=rowMetaData;
                prepopulatedMetaData.ColumnMetaData=columnMetaData;
                prepopulatedMetaData.TableMetaData=tableMetaData;
                prepopulatedMetaData.CellMetaData=cellMetaData;
                subtype=internal.matlab.variableeditor.peer.PeerUtils.formatClass(originalValue);
                type=subtype;
                if(tabularType.isObject&&~tabularType.isStruct)
                    subtype='object';
                end

                mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);

                outputData.name=variableName;
                outputData.value=valueString;
                outputData.header=header;
                outputData.type=type;
                outputData.rows=totalRows;
                outputData.columns=totalColumns;
                outputData.truncationInfo=truncationInfo;
                outputData.doc_id=docID;
                outputData.ve_channel=mgr.Channel;
                outputData.subtype=subtype;
                outputData.prepopulatedMetaData={jsonencode(prepopulatedMetaData)};
                outputData.prepopulatedData={jsonencode(struct('value',prepopulatedData))};

                if~isempty(validAttributes)
                    outputData.dataAttributes=validAttributes;
                end




                outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
            end
        end

        function[prepopulatedData,data]=getPrepopulatedData(tabularType,partialData,originalData,rows,columns,isPreview)
            if(tabularType.isCell)
                [data,~,metaData]=internal.matlab.variableeditor.CellArrayViewModel.getParsedCellArrayData(partialData,1,rows,1,columns);
                [prepopulatedData]=internal.matlab.variableeditor.peer.RemoteCellArrayViewModel.getJSONForCellData(data,partialData,metaData,1,1);
                prepopulatedData=cellstr(prepopulatedData);
            elseif(tabularType.isStruct&&~tabularType.isObject)
                dataAsCell=internal.matlab.datatoolsservices.FormatDataUtils.convertStructToCell(originalData);
                [data,~,metaData]=internal.matlab.variableeditor.StructureArrayViewModel.getParsedStructArrayData(originalData,dataAsCell,1,rows,1,columns);
                [prepopulatedData]=internal.matlab.variableeditor.peer.RemoteStructureArrayViewModel.getJSONForStructureArrayData(data,originalData,dataAsCell,metaData,1,1);
            elseif(tabularType.isObject)
                if isnumeric(originalData)
                    import matlab.internal.editor.interactiveVariables.*;
                    [data,dataSubset]=InteractiveNumericsPackager.getDataWithDataTipInfo(originalData,partialData(1:rows,1:columns),isPreview);

                    [prepopulatedData,~,~,data]=internal.matlab.variableeditor.peer.RemoteNumericArrayViewModel.getJSONForNumericData(data,dataSubset,1,rows,1,columns,'liveeditor',string(-1));
                else
                    [data]=internal.matlab.variableeditor.ObjectArrayViewModel.getParsedObjectArrayData(partialData,1,rows,1,columns);
                    [prepopulatedData]=internal.matlab.variableeditor.peer.RemoteObjectArrayViewModel.getJSONForObjectArrayData(data,1,1);
                end
            end
        end

        function cellMetaData=getCellMetaData(tabularType,partialData,~,rows,columns)
            cellMetaData={};
            import matlab.internal.editor.interactiveVariables.*;
            if(tabularType.isCell)
                cellMetaData=InteractiveTabularPackager.getJSONCellMetadata(partialData,1,rows,1,columns);
            elseif(tabularType.isStruct&&~tabularType.isObject)
                cellMetaData=InteractiveTabularPackager.getJSONStructMetadata(partialData,1,rows,1,columns);
            else
                jsonencode(cellMetaData);
            end
        end

        function[cellModelProps]=getJSONCellMetadata(data,startRow,endRow,startColumn,endColumn)
            rmpca=cell(1,endRow-startRow+1);
            for row=startRow:endRow
                cmpca=cell(1,endColumn-startColumn+1);
                for column=startColumn:endColumn
                    val=data{row,column};
                    className=internal.matlab.datatoolsservices.FormatDataUtils.getLookupClassName(class(data),val);
                    cellMetaData=struct('class',className);
                    cmpca{column-startColumn+1}=jsonencode(cellMetaData);
                end
                rmpca{row-startRow+1}='[';
                if~isempty(cmpca)&&~isempty(cmpca{endColumn-startColumn+1})
                    rmpca{row-startRow+1}=[rmpca{row-startRow+1},strjoin(cmpca,',')];
                end
                rmpca{row-startRow+1}=[rmpca{row-startRow+1},']'];
            end

            cellModelProps='[';
            if~isempty(rmpca)
                cellModelProps=[cellModelProps,strjoin(rmpca,',')];
            end
            cellModelProps=[cellModelProps,']'];
        end

        function[cellModelProps]=getJSONStructMetadata(data,startRow,endRow,startColumn,endColumn)
            rmpca=cell(1,endRow-startRow+1);
            for row=startRow:endRow
                cmpca=cell(1,endColumn-startColumn+1);
                for column=startColumn:endColumn



                    [~,colClassName]=internal.matlab.datatoolsservices.FormatDataUtils.uniformTypeData(data(:,column));
                    if(strcmp(colClassName,'mixed'))
                        cellClassName=internal.matlab.datatoolsservices.FormatDataUtils.getLookupClassName(class(data),data{row,column});
                        cellMetaData=struct('class',cellClassName);
                    else
                        cellMetaData=struct;
                    end
                    cmpca{column-startColumn+1}=jsonencode(cellMetaData);
                end
                rmpca{row-startRow+1}='[';
                if~isempty(cmpca)&&~isempty(cmpca{endColumn-startColumn+1})
                    rmpca{row-startRow+1}=[rmpca{row-startRow+1},strjoin(cmpca,',')];
                end
                rmpca{row-startRow+1}=[rmpca{row-startRow+1},']'];
            end
            cellModelProps='[';
            if~isempty(rmpca)
                cellModelProps=[cellModelProps,strjoin(rmpca,',')];
            end
            cellModelProps=[cellModelProps,']'];
        end

        function cmpca=getColumnMetaData(tabularType,partialData,originalData,columns,formattedData)
            import matlab.internal.editor.interactiveVariables.InteractiveTabularUtils;
            cmpca=cell(1,columns);
            varSize=size(originalData);


            isStructArrayType=tabularType.isStruct&&~tabularType.isObject&&(varSize(1)==1||varSize(2)==1);
            structureArrayFieldNames=[];
            if isStructArrayType
                structureArrayFieldNames=fields(originalData);
            end
            rowCutOff=min(InteractiveTabularUtils.ROW_TRUNCATION_LIMIT,varSize(1));
            for col=1:columns
                colMetaData=struct;
                if isStructArrayType
                    [~,colClassName]=internal.matlab.datatoolsservices.FormatDataUtils.uniformTypeData(partialData(:,col));
                    if~strcmp(colClassName,'mixed')
                        colClassName=internal.matlab.datatoolsservices.FormatDataUtils.getLookupClassName(class(originalData),partialData{1,col});
                    end
                    colMetaData=struct('columnClass',colClassName,'columnHeaderLabels',structureArrayFieldNames{col});
                end
                colMetaData.columnWidth=InteractiveTabularUtils.getColumnWidthForData(formattedData(1:rowCutOff,:),col,structureArrayFieldNames);
                cmpca{col}=colMetaData;
            end
        end

        function rowMetaData=getRowMetaData(~,~,~,~)
            rowMetaData=[];
        end

        function tableMetadata=getTableMetaData(tabularType,~,~)
            tableMetadata=struct;
            if(tabularType.isStruct&&~tabularType.isObject)
                tableMetadata.CornerSpacerTitle=getString(message(...
                'MATLAB:codetools:variableeditor:Fields'));
            elseif(tabularType.isObject)
                tableMetadata.class="object";
            end
        end
    end
end
