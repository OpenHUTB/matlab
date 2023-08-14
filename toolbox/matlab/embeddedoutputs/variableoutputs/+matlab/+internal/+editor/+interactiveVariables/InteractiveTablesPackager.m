classdef InteractiveTablesPackager






    properties(Hidden)
        isTesting;
    end

    properties(Constant)
        ROW_TRUNCATION_LIMIT=16;
        MAX_ROWS_TABLES=14;
        MAX_COLUMNS_ALLOWED_INTERACTIVEVIEW=5000;
    end
    methods(Static)
        function[outputType,outputData]=packageVarTable(variableName,variableValue,...
            header,editorId,isPreview,requestId)

            import matlab.internal.editor.EODataStore;
            import matlab.internal.editor.interactiveVariables.*;
            import matlab.internal.editor.OutputPackagerUtilities;
            import matlab.internal.editor.VariableUtilities;

            variableSize=size(variableValue);
            partialRows=min(InteractiveTablesPackager.MAX_ROWS_TABLES,variableSize(1));
            partialColumns=min(InteractiveTabularUtils.MAX_COLS_PAGE_SIZE,variableSize(2));

            valueString='';
            truncationInfo='';
            if nargin<5||(nargin>4&&~isPreview)
                [valueString,truncationInfo]=InteractiveTabularUtils.getTruncatedStringFromTable(variableName,...
                variableValue,header,InteractiveTablesPackager.ROW_TRUNCATION_LIMIT);
            end



            isMaxOutputs=InteractiveVariablesPackager.isMaxInteractiveOutputs(editorId,requestId)&&~isPreview;
            shouldPackageAsInteractive=~(isMaxOutputs||InteractiveTablesPackager.isColNumExceedsLimitOrHasEmpties(variableValue));
            if shouldPackageAsInteractive



                isSynchronous=EODataStore.getRootField('SynchronousOutput');
                isSynchronous=~isempty(isSynchronous)&&isSynchronous;
                shouldPackageAsInteractive=~isSynchronous;
            end

            if~shouldPackageAsInteractive
                [outputType,outputData]=InteractiveTabularUtils.createLegacyOutput(variableName,valueString,header,truncationInfo);
            else
                docID=InteractiveTabularUtils.createVariableView(editorId,variableName,variableValue,isPreview,requestId);




                try
                    partialValue=variableValue(1:partialRows,1:partialColumns);
                catch
                    partialValue=variableValue;
                end
                totalRows=size(variableValue,1);
                totalColumns=size(variableValue,2);

                isSortable=false(1,totalColumns);
                isFilterable=false(1,totalColumns);


                for i=1:partialColumns
                    isSortable(i)=internal.matlab.variableeditor.peer.PeerUtils.checkIsSortable(variableValue(:,i),isPreview);
                    isFilterable(i)=internal.matlab.variableeditor.peer.PeerUtils.checkIsFilterable(variableValue(:,i),isPreview);
                end

                if isa(variableValue,'timetable')



                    if(isscalar(variableValue))
                        header=[' ',num2str(totalRows),matlab.internal.display.getDimensionSpecifier...
                        ,num2str(totalColumns),header];
                    end
                    partialValue=timetable2table(partialValue);
                    partialColumns=partialColumns+1;
                    totalColumns=totalColumns+1;
                    isSortable=[true,isSortable];
                    isFilterable=[true,isFilterable];
                end
                tableMetaData=internal.matlab.variableeditor.peer.PeerUtils.getTableMetaData(partialValue);
                columnClasses=InteractiveTablesPackager.getClassNames(partialValue);

                prepopulatedData=internal.matlab.variableeditor.peer.PeerDataUtils.getTableRenderedDataForPeer(partialValue);
                subtype=class(variableValue);
                columnHeaderLabels=partialValue.Properties.VariableNames(1:partialColumns);
                if isa(variableValue,'timetable')
                    rowHeaderLabels={};
                elseif~isempty(variableValue.Properties.RowNames)
                    rowHeaderLabels=partialValue.Properties.RowNames(1:partialRows);
                else
                    rowHeaderLabels={};
                end

                mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);
                veAttributes=internal.matlab.variableeditor.VEDataAttributes(variableValue);
                [~,validAttributes]=internal.matlab.datatoolsservices.WidgetRegistry.getDataAttributes(veAttributes,variableSize);


                columnMetaData=InteractiveTablesPackager.getColumnMetaData(partialValue,columnHeaderLabels,partialColumns,variableSize(1));
                prepopulatedMetaData=struct;
                prepopulatedMetaData.ColumnMetaData=columnMetaData;


                outputData.name=variableName;
                outputData.value=valueString;
                outputData.header=header;
                outputData.rows=totalRows;
                outputData.columns=totalColumns;
                outputData.truncationInfo=truncationInfo;
                outputData.doc_id=docID;
                outputData.ve_channel=mgr.Channel;
                outputData.subtype=subtype;
                outputData.metadata=tableMetaData;
                outputData.columnClass=columnClasses;
                outputData.prepopulatedData={jsonencode(struct('value',prepopulatedData))};
                outputData.viewType='';
                outputData.isSortable=isSortable;
                outputData.isFilterable=isFilterable;
                outputData.exponent='1';
                outputData.columnHeaderLabels=columnHeaderLabels;
                outputData.prepopulatedMetaData={jsonencode(prepopulatedMetaData)};
                if~isempty(rowHeaderLabels)
                    outputData.rowHeaderLabels=rowHeaderLabels;
                end
                if~isempty(validAttributes)
                    outputData.dataAttributes=validAttributes;
                end





                outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
            end
        end




        function classNames=getClassNames(variableValue)
            classNames=strings(1,size(variableValue,2));
            widgetRegistry=internal.matlab.datatoolsservices.WidgetRegistry.getInstance;
            for i=1:size(variableValue,2)
                try
                    val=variableValue{1,i};
                    classname=class(val);
                    [~,~,matchedVariableClass]=widgetRegistry.getWidgets(class(variableValue),classname);
                    if(isobject(val)||isempty(meta.class.fromName(class(val))))&&isempty(matchedVariableClass)
                        classname='object';
                        [~,~,matchedVariableClass]=widgetRegistry.getWidgets(class(variableValue),classname);
                    end
                    if~strcmp(classname,matchedVariableClass)
                        classname=matchedVariableClass;
                    end
                    if(iscellstr(val))
                        classname='cellstr';
                    end
                catch
                    classname='object';
                end
                classNames(1,i)=string(classname);
            end
        end


        function cmpca=getColumnMetaData(variableValue,headerLabels,columnCount,rowCount)
            import matlab.internal.editor.interactiveVariables.InteractiveTabularUtils;
            rowCutOff=min(InteractiveTabularUtils.ROW_TRUNCATION_LIMIT,rowCount);
            formattedData=internal.matlab.variableeditor.peer.PeerDataUtils.getTableRenderedData(variableValue(1:rowCutOff,:));
            cmpca=cell(1,columnCount);
            for col=1:columnCount
                width=InteractiveTabularUtils.getColumnWidthForData(formattedData,col,headerLabels);
                cmpca{col}=struct('columnWidth',width);
            end
        end
    end

    methods(Static,Hidden)


        function b=isColNumExceedsLimitOrHasEmpties(value)
            import matlab.internal.editor.interactiveVariables.InteractiveTablesPackager

            varSize=internal.matlab.datatoolsservices.FormatDataUtils.getActualTableSize(value);
            columnsNumberExceedsLimit=varSize(2)>InteractiveTablesPackager.MAX_COLUMNS_ALLOWED_INTERACTIVEVIEW;

            w(1)=warning('off',"MATLAB:table:ModifiedVarnames");
            w(2)=warning('off',"MATLAB:table:ModifiedVarnamesLengthMax");
            c=onCleanup(@()warning(w));
            hasEmptyColumns=(any(table2array(varfun(@isempty,value,'OutputFormat','table')))&&~isempty(value));

            b=columnsNumberExceedsLimit||hasEmptyColumns;
        end
    end
end
