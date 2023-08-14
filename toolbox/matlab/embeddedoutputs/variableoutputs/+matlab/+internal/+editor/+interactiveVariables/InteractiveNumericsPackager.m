classdef InteractiveNumericsPackager







    properties(Hidden)
        isTesting;
    end

    properties(Constant)






        MAX_ROWS_MATRIX=10;
        MAX_COLS_MATRIX=50;
        MAX_COLS_PAGE_SIZE=30;
    end

    methods(Static)

        function[outputType,outputData]=packageVarMatrix(variableName,variableValue,...
            header,editorId,storeVariable,isPreview,requestId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager
            import matlab.internal.editor.interactiveVariables.InteractiveTabularUtils
            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.EODataStore




            rows=min(InteractiveNumericsPackager.MAX_ROWS_MATRIX,size(variableValue,1));
            columns=min(InteractiveNumericsPackager.MAX_COLS_PAGE_SIZE,size(variableValue,2));


            isMaxOutputs=InteractiveVariablesPackager.isMaxInteractiveOutputs(editorId,requestId)&&~isPreview;
            shouldPackageAsInteractive=~isMaxOutputs;
            isSynchronous=false;
            if shouldPackageAsInteractive



                isSynchronous=EODataStore.getRootField('SynchronousOutput');
                isSynchronous=~isempty(isSynchronous)&&isSynchronous;
                shouldPackageAsInteractive=~isSynchronous;
            end


            if isSynchronous&&~isreal(variableValue)
                [valueString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);
                [outputType,outputData]=InteractiveTabularUtils.createLegacyOutput(variableName,valueString,header,truncationInfo);
            elseif~shouldPackageAsInteractive
                [outputType,outputData]=InteractiveNumericsPackager.getLegacyMatrixOutput(variableName,variableValue,...
                editorId,storeVariable,isPreview,rows,columns);
            else


                [fullData,dataSubset]=InteractiveNumericsPackager.getDataWithDataTipInfo(variableValue,variableValue(1:rows,1:columns),isPreview);
                [prepopulatedData,~,scalingFactorString]=internal.matlab.variableeditor.peer.RemoteNumericArrayViewModel.getJSONForNumericData(fullData,dataSubset,1,rows,1,columns,'liveeditor',string(-1));
                scalingFactor=str2double(scalingFactorString);

                outputData=InteractiveNumericsPackager.getVariableOutputData(variableName,variableValue,...
                header,editorId,prepopulatedData,scalingFactor,isPreview);

                InteractiveVariablesPackager.incrementDocumentCount(editorId,requestId);





                outputType='matrix';
            end
        end


        function[outputType,outputData]=getLegacyMatrixOutput(variableName,variableValue,...
            editorId,storeVariable,isPreview,rows,columns)
            import matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager
            import matlab.internal.editor.VariableManager
            variableSize=size(variableValue);
            header=[num2str(variableSize(1)),internal.matlab.datatoolsservices.FormatDataUtils.TIMES_SYMBOL,num2str(variableSize(2))];
            [~,scalingFactor]=internal.matlab.variableeditor.peer.PeerDataUtils.getDisplayDataAsString(variableValue,variableValue(1:rows,1:columns),true,false);

            valueString=InteractiveNumericsPackager.getChoppedStringFromVar(variableName,variableValue,rows,columns,header,scalingFactor,isPreview);


            id=[];
            if storeVariable
                id=VariableManager.storeVariable(editorId,variableName,variableValue);
            end

            outputData.name=variableName;
            outputData.value=valueString;
            outputData.header=header;
            outputData.type=class(variableValue);
            outputData.id=id;
            outputData.rows=variableSize(1);
            outputData.columns=variableSize(2);
            outputType='matrix';
        end


        function[outputType,outputData]=packageVarLogical(variableName,variableValue,...
            header,editorId,storeVariable,isPreview,requestId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager
            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.VariableUtilities;

            isMaxOutputs=InteractiveVariablesPackager.isMaxInteractiveOutputs(editorId,requestId)&&~isPreview;
            import matlab.internal.editor.EODataStore
            isSynchronous=EODataStore.getRootField('SynchronousOutput');
            isSynchronous=~isempty(isSynchronous)&&isSynchronous;
            if InteractiveNumericsPackager.useLegacyView(variableValue,editorId,requestId)||...
                isMaxOutputs||isa(variableValue,'matlab.lang.OnOffSwitchState')||isSynchronous
                [valueString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);

                outputData.name=variableName;
                outputData.value=valueString;
                outputData.header=header;
                outputData.truncationInfo=truncationInfo;
                outputData.rows=1;
                outputData.columns=1;
            else


                rows=min(InteractiveNumericsPackager.MAX_ROWS_MATRIX,size(variableValue,1));
                columns=min(InteractiveNumericsPackager.MAX_COLS_PAGE_SIZE,size(variableValue,2));
                rawData=internal.matlab.variableeditor.peer.PeerDataUtils.getDisplayDataAsString(variableValue,variableValue(1:rows,1:columns),false,false);
                prepopulatedData=internal.matlab.variableeditor.peer.RemoteLogicalArrayViewModel.getJSONForLogicalData(...
                rawData,1,rows,1,columns);
                InteractiveVariablesPackager.incrementDocumentCount(editorId,requestId);

                outputData=InteractiveNumericsPackager.getVariableOutputData(variableName,variableValue,...
                header,editorId,prepopulatedData,1,isPreview);



            end
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
        end



        function variableOutputData=getVariableOutputData(variableName,variableValue,...
            header,editorId,prepopulatedData,scalingFactor,isPreview)



            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager

            dimensions=size(variableValue);
            if issparse(variableValue)
                rows=dimensions(1);
                columns=dimensions(2);
            else


                rows=min(InteractiveNumericsPackager.MAX_ROWS_MATRIX,size(variableValue,1));
                columns=min(InteractiveNumericsPackager.MAX_COLS_PAGE_SIZE,size(variableValue,2));
            end




            [valueString,numDisplayFormat]=InteractiveNumericsPackager.getChoppedStringFromVar(variableName,variableValue,min(InteractiveNumericsPackager.MAX_ROWS_MATRIX,rows),dimensions(2),header,scalingFactor,isPreview);
            mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);
            if~isPreview
                docID=mgr.openvar(variableName,'base',variableValue,UserContext='liveeditor',DelayDocCreation=true,DisplayFormat=numDisplayFormat);
                InteractiveVariablesPackager.queueAsyncVariableCreation(editorId);
            else
                docID='_datatip';
            end


            exponent=1;
            if~(scalingFactor==1)
                exponent=log10(scalingFactor);
            end


            if~isreal(variableValue)
                subtype='complex';
            else
                subtype=class(variableValue);
            end

            viewType='variableeditor_peer/PeerArrayViewModel';
            isSortable=false(1,columns);
            isFilterable=false(1,columns);

            variableOutputData=struct(...
            'name',variableName,...
            'value',valueString,...
            'header',header,...
            'type',subtype,...
            'rows',dimensions(1),...
            'columns',dimensions(2),...
            'doc_id',docID,...
            've_channel',mgr.Channel,...
            'subtype',subtype,...
            'prepopulatedData',{{jsonencode(struct('value',prepopulatedData))}},...
            'viewType',viewType,...
            'isSortable',isSortable,...
            'isFilterable',isFilterable,...
            'exponent',string(exponent)...
            );
        end

        function[valueString,currentNumFormat]=getChoppedStringFromVar(variableName,variableValue,rows,columns,header,scalingFactor,isPreview)



            import matlab.internal.editor.VariableOutputPackager;
            import matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager



            nRows=min(InteractiveNumericsPackager.MAX_ROWS_MATRIX,rows);
            nCols=min(InteractiveNumericsPackager.MAX_COLS_MATRIX,columns);
            currentNumFormat='';
            if(nargin<6)||isempty(scalingFactor)
                scalingFactor=1;
                isPreview=0;
            elseif(nargin<7)
                isPreview=0;
            end

            if ismatrix(variableValue)&&(isnumeric(variableValue)||islogical(variableValue))&&~isempty(variableValue)


                [fullData,dataSubset]=InteractiveNumericsPackager.getDataWithDataTipInfo(variableValue,variableValue(1:nRows,1:nCols),isPreview);


                s=settings;
                currentNumFormat=s.matlab.commandwindow.NumericFormat.ActiveValue;
                if scalingFactor~=1
                    [valueString,scalingFactor]=internal.matlab.variableeditor.peer.PeerDataUtils.getDisplayDataAsString(fullData,dataSubset,true,true,currentNumFormat);
                    valueString=char(valueString);


                    valueString=sprintf("%0.1e *\n\n%s",scalingFactor,valueString);
                else
                    [valueString,subsetScalingFactor]=internal.matlab.variableeditor.peer.PeerDataUtils.getDisplayDataAsString(fullData,dataSubset,true,false,currentNumFormat);






                    if~isPreview&&subsetScalingFactor~=1
                        valueString=internal.matlab.variableeditor.peer.PeerDataUtils.getDisplayDataAsString(fullData,dataSubset,true,true,currentNumFormat);
                    end
                    valueString=char(valueString);
                end
            else
                valueString=VariableOutputPackager.getStringFromVar(variableName,variableValue(1:nRows,1:nCols),header);
            end
        end



        function[fullData,dataSubset]=getDataWithDataTipInfo(allData,subset,isPreview)
            dataSubset=subset;

            if~isPreview
                fullData=allData;
            else



                if~isreal(allData)
                    fullData=complex(subset);
                else
                    fullData=subset;
                end
            end
        end

        function isLegacyView=useLegacyView(data,editorId,requestId)
            isLegacyView=issparse(data)||isscalar(data)||~ismatrix(data);
        end
    end
end
