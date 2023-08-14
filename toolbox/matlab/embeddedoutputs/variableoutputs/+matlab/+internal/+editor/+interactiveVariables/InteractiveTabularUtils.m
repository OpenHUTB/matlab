classdef InteractiveTabularUtils







    properties(Constant)






        ROW_TRUNCATION_LIMIT=10;
        MAX_ROWS_TABLES=10;
        MAX_COLS_PAGE_SIZE=30;
    end

    methods(Static)
        function[rows,columns]=getDimensionsForPackaging(variable)


            import matlab.internal.editor.interactiveVariables.InteractiveTabularUtils;
            rows=min(InteractiveTabularUtils.MAX_ROWS_TABLES,size(variable,1));
            columns=min(InteractiveTabularUtils.MAX_COLS_PAGE_SIZE,size(variable,2));
        end

        function[outputType,outputData]=createLegacyOutput(variableName,valueString,header,truncationInfo)
            import matlab.internal.editor.VariableUtilities;
            outputData.name=variableName;
            outputData.value=valueString;
            outputData.header=header;
            outputData.truncationInfo=truncationInfo;
            outputData.rows=1;
            outputData.columns=1;
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
        end

        function docID=createVariableView(editorId,variableName,variableValue,isPreview,requestId)
            import matlab.internal.editor.interactiveVariables.*
            mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);
            s=settings;
            numDisplayFormat=s.matlab.commandwindow.NumericFormat.ActiveValue;
            docID=mgr.openvar(variableName,'base',variableValue,UserContext='liveeditor',DelayDocCreation=true,DisplayFormat=numDisplayFormat);
            if~isPreview
                InteractiveVariablesPackager.queueAsyncVariableCreation(editorId);
            end
            InteractiveVariablesPackager.incrementDocumentCount(editorId,requestId);
            formatDataUtils=internal.matlab.datatoolsservices.FormatDataUtils;
            formatDataUtils.setRowLimitCutoff("liveeditor",InteractiveTabularUtils.ROW_TRUNCATION_LIMIT)
        end
    end


    methods(Static,Hidden)

        function colWidth=getColumnWidthForData(formattedData,col,headerLabels)
            width=internal.matlab.variableeditor.VEColumnConstants.defaultColumnWidth;
            if~isempty(headerLabels)
                width=max(width,internal.matlab.datatoolsservices.FormatDataUtils.computeHeaderWidthUsingLabels(headerLabels{col}));
            end
            data=formattedData(:,col);
            widths=cellfun(@matlab.internal.display.wrappedLength,data);
            overallWidth=max(sum(max(widths))*internal.matlab.datatoolsservices.FormatDataUtils.CHAR_WIDTH,width);
            colWidth=min(overallWidth,internal.matlab.variableeditor.VEColumnConstants.MAX_COL_WIDTH);
        end

        function[truncatedString,truncationInfo]=getTruncatedStringFromTable(variableName,variableValue,header,rowTruncationLimit)


            import matlab.internal.editor.interactiveVariables.InteractiveTabularUtils;
            import matlab.internal.editor.VariableOutputPackager
            if(nargin<4)
                rowTruncationLimit=InteractiveTabularUtils.ROW_TRUNCATION_LIMIT;
            end



            displayTableSubset=size(variableValue,1)>rowTruncationLimit;
            if displayTableSubset
                variableValue=variableValue(1:rowTruncationLimit,:);
            end




            [truncatedString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);
            hadAdditionalTruncation=truncationInfo.wasTruncatedMidLine||truncationInfo.wasTruncatedAtLineBreak;

            if displayTableSubset&&~hadAdditionalTruncation
                truncationInfo.wasTruncatedMidLine=false;
                truncationInfo.wasTruncatedAtLineBreak=true;
            end
        end
    end
end

