classdef InteractiveVariablesPackager








    properties(Hidden)
        isTesting;
    end

    properties(Constant)
        ActionManagerNamespace='_Actions';
        startPath='internal.matlab.variableeditor.Actions';
        MaxOutputs=50;
    end

    methods(Static)
        function maxOutputs=getMaxOutputs()
            s=settings;
            st=s.matlab.liveeditor.LiveEditorInteractiveOutputs;
            if st.hasPersonalValue
                maxOutputs=str2double(st.PersonalValue);
            else
                maxOutputs=str2double(st.ActiveValue);
            end
        end

        function[docCount,docCounterKey]=getDocumentCount(editorId,requestId)
            import matlab.internal.editor.EODataStore

            docCounterKey=['InteractiveVars_Doc_Counter_',requestId];
            docCount=EODataStore.getEditorField(editorId,docCounterKey);
            if isempty(docCount)
                docCount=0;
            end
        end

        function docCount=incrementDocumentCount(editorId,requestId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.EODataStore

            [docCount,docCounterKey]=InteractiveVariablesPackager.getDocumentCount(editorId,requestId);
            docCount=docCount+1;
            EODataStore.setEditorField(editorId,docCounterKey,docCount);
        end

        function isMaxOutputs=isMaxInteractiveOutputs(editorId,requestId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager

            docCount=InteractiveVariablesPackager.getDocumentCount(editorId,requestId);
            isMaxOutputs=docCount>=InteractiveVariablesPackager.MaxOutputs;
        end

        function queueAsyncVariableCreation(editorId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager

            mgr=InteractiveVariablesPackager.getVariableEditorManager(editorId);
            mgr.asyncDoDelayedDocumentCreation();
        end

        function mgr=getVariableEditorManager(editorId)
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager

            ve_channel=['/LE_EO_',editorId];
            mgr=internal.matlab.variableeditor.peer.VEFactory.createManager(ve_channel,true,...
            struct('initActionManager',struct('ActionManagerNamespace',InteractiveVariablesPackager.ActionManagerNamespace,...
            'startPath',InteractiveVariablesPackager.startPath)));
        end

        function clearVariableEditorOutputs(editorId)
            m=internal.matlab.variableeditor.peer.VEFactory.getManagerInstances();
            channel=['/LE_EO_',editorId];
            if isKey(m,channel)
                mgr=m(channel);
                if~isempty(mgr)
                    for i=1:length(mgr.Documents)

                        filterChannel=['/VE/filter',mgr.Documents(i).DocID];
                        if isKey(m,filterChannel)
                            delete(m(filterChannel));
                        end


                        catCleanerChannel=[channel,'/categoricalCleaner'];
                        if isKey(m,catCleanerChannel)
                            delete(m(catCleanerChannel));
                        end
                    end
                    delete(mgr);
                end
            end

            internal.matlab.datatoolsservices.DialogHandlerService.closeAllDialogs(channel);
        end



        function isInteractive=isInteractiveOutput(variableValue)
            isInteractive=false;
            import matlab.internal.editor.interactiveVariables.*



            if isa(variableValue,'logical')||...
                InteractiveVariablesPackager.IsTextLikeTypes(variableValue)||...
                (InteractiveVariablesPackager.IsTabularLikeTypes(variableValue)&&...
                InteractiveVariablesPackager.isValidArrayType(variableValue))
                isInteractive=true;
            end
        end



        function isInteractive=isInteractiveObjectArray(variableValue)
            import matlab.internal.editor.interactiveVariables.*
            isInteractive=isobject(variableValue)||all(all(ishandle(variableValue)));


            if isInteractive&&(~isscalar(variableValue)&&numel(variableValue)==1)
                dataAttr=internal.matlab.variableeditor.VEDataAttributes.updateAttributesForObjectData(...
                variableValue,struct('isUnsupported',false,'isScalar',false));
                isInteractive=isInteractive&&~(dataAttr.isScalar||dataAttr.isUnsupported);
            end
        end



        function[outputType,outputData]=packageVarNumeric(variableName,variableValue,...
            header,editorId,storeVariable,isPreview,requestId)
            [outputType,outputData]=matlab.internal.editor.interactiveVariables.InteractiveNumericsPackager.packageVarMatrix(variableName,variableValue,...
            header,editorId,storeVariable,isPreview,requestId);
        end

        function[outputType,outputData]=packageVarInteractive(variableName,variableValue,...
            header,editorId,storeVariable,isPreview,requestId)
            import matlab.internal.editor.interactiveVariables.*
            if isa(variableValue,'logical')
                [outputType,outputData]=InteractiveNumericsPackager.packageVarLogical(variableName,variableValue,...
                header,editorId,storeVariable,isPreview,requestId);
            elseif isa(variableValue,'table')||isa(variableValue,'timetable')
                [outputType,outputData]=InteractiveTablesPackager.packageVarTable(variableName,...
                variableValue,header,editorId,...
                isPreview,requestId);
            elseif InteractiveVariablesPackager.IsTextLikeTypes(variableValue)
                [outputType,outputData]=InteractiveTextMatrixPackager.packageVarTextMatrix(variableName,...
                variableValue,header,editorId,...
                isPreview,requestId);
            elseif(InteractiveVariablesPackager.IsTabularLikeTypes(variableValue)||...
                InteractiveVariablesPackager.isInteractiveObjectArray(variableValue))
                [outputType,outputData]=InteractiveTabularPackager.packageVarTabularOutput(variableName,...
                variableValue,header,editorId,...
                isPreview,requestId);
            end
        end

        function isTextType=IsTextLikeTypes(variableValue)
            isTextType=(isstring(variableValue)||isa(variableValue,'categorical')||...
            isa(variableValue,'datetime')||isa(variableValue,'duration')||isa(variableValue,'calendarDuration')||...
            iscellstr(variableValue));
        end

        function isTabularType=IsTabularLikeTypes(variableValue)
            import matlab.internal.editor.interactiveVariables.*
            isTabularType=(isa(variableValue,'table')||isa(variableValue,'timetable')||...
            (iscell(variableValue)&&~iscellstr(variableValue))||...
            isstruct(variableValue));
        end


        function isValid=isValidArrayType(variableValue)
            obj=internal.matlab.datatoolsservices.DefaultDataAttributes(variableValue,size(variableValue));
            if isa(variableValue,'collection')


                obj.('isScalar')=false;
            end


            isValid=((isa(variableValue,'table')||isa(variableValue,'timetable'))||~obj.isScalar)&&~obj.isND&&~obj.isEmpty;
        end
    end
end
