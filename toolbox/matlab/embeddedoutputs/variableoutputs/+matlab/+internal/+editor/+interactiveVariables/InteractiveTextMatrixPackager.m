classdef InteractiveTextMatrixPackager







    properties(Constant)
        ROW_TRUNCATION_LIMIT=30;
    end

    methods(Static)

        function[outputType,outputData]=packageVarTextMatrix(variableName,variableValue,...
            header,editorId,isPreview,requestId)
            import matlab.internal.editor.interactiveVariables.*;
            import matlab.internal.editor.VariableUtilities;
            [partialRows,partialColumns]=InteractiveTabularUtils.getDimensionsForPackaging(variableValue);


            valueString='';
            truncationInfo='';
            if nargin<5||(nargin>4&&(~isPreview||isscalar(variableValue)))
                [valueString,truncationInfo]=InteractiveTabularUtils.getTruncatedStringFromTable(variableName,variableValue,header,...
                InteractiveTextMatrixPackager.ROW_TRUNCATION_LIMIT);
            end



            isMaxOutputs=InteractiveVariablesPackager.isMaxInteractiveOutputs(editorId,requestId)&&~isPreview;
            import matlab.internal.editor.EODataStore
            isSynchronous=EODataStore.getRootField('SynchronousOutput');
            isSynchronous=~isempty(isSynchronous)&&isSynchronous;
            if isMaxOutputs||~ismatrix(variableValue)||isscalar(variableValue)||isSynchronous
                [outputType,outputData]=InteractiveTabularUtils.createLegacyOutput(variableName,valueString,header,truncationInfo);
            else
                docID=InteractiveTabularUtils.createVariableView(editorId,variableName,variableValue,isPreview,requestId);
                dataSize=size(variableValue);
                [prepopulatedData,prepopulatedMetaData]=InteractiveTextMatrixPackager.getPrepopulatedDataForOutput(variableValue,partialRows,partialColumns,dataSize);
                subtype=class(variableValue);

                veAttributes=internal.matlab.variableeditor.VEDataAttributes(variableValue);
                [~,validAttributes]=internal.matlab.datatoolsservices.WidgetRegistry.getDataAttributes(veAttributes,dataSize);

                mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);

                outputData.name=variableName;
                outputData.value=valueString;
                outputData.header=header;
                outputData.type=subtype;
                outputData.rows=dataSize(1);
                outputData.columns=dataSize(2);
                outputData.truncationInfo=truncationInfo;
                outputData.doc_id=docID;
                outputData.ve_channel=mgr.Channel;
                outputData.subtype=subtype;
                if(~iscell(prepopulatedData))
                    prepopulatedData=cellstr(prepopulatedData);
                end
                outputData.prepopulatedData={jsonencode(struct('value',prepopulatedData))};
                outputData.viewType='';
                outputData.exponent='1';
                if~isempty(prepopulatedMetaData)
                    outputData.prepopulatedMetaData={jsonencode(prepopulatedMetaData)};
                end
                if~isempty(validAttributes)
                    outputData.dataAttributes=validAttributes;
                end

                outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
            end
        end



        function[prepopulatedData,prepopulatedMetaData]=getPrepopulatedDataForOutput(variableValue,partialRows,partialColumns,dataSize)
            partialValue=variableValue(1:partialRows,1:partialColumns);
            prepopulatedMetaData=[];
            if isa(variableValue,'string')
                [prepopulatedData,~,metaData]=internal.matlab.variableeditor.StringArrayViewModel.getParsedStringData(partialValue);
                if(any(any(metaData)))
                    prepopulatedMetaData=struct;
                    rmpca=cell(1,partialRows);
                    for row=1:partialRows
                        cmpca=cell(1,partialColumns);
                        for column=1:partialColumns
                            md='{}';
                            if(metaData(row,column))
                                md=jsonencode(struct('isMetaData',true));
                            end
                            cmpca{column}=md;
                        end
                        rmpca{row}=['[',strjoin(cmpca,','),']'];
                    end
                    prepopulatedMetaData.CellMetaData=['[',strjoin(rmpca,','),']'];
                end
            elseif isa(variableValue,'categorical')
                [prepopulatedData]=internal.matlab.variableeditor.ArrayViewModel.getParsedArrayData(partialValue);
            elseif isa(variableValue,'datetime')
                [prepopulatedData]=internal.matlab.variableeditor.DatetimeArrayViewModel.getParsedDatetimeData(partialValue);
            elseif isa(variableValue,'duration')
                [prepopulatedData]=internal.matlab.variableeditor.DurationArrayViewModel.getParsedDurationData(partialValue);
            elseif isa(variableValue,'calendarDuration')
                [prepopulatedData]=internal.matlab.variableeditor.CalendarDurationArrayViewModel.getParsedCalendarDurationData(partialValue);
            elseif iscellstr(variableValue)
                [data,~,metaData]=internal.matlab.variableeditor.CellArrayViewModel.getParsedCellArrayData(partialValue,1,partialRows,1,partialColumns);
                [prepopulatedData]=internal.matlab.variableeditor.peer.RemoteCellArrayViewModel.getJSONForCellData(data,partialValue,metaData,1,1);
                prepopulatedData=cellstr(prepopulatedData);
            end
        end
    end
end
