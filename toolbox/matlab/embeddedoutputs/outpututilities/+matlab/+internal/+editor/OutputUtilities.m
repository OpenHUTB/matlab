classdef OutputUtilities






    properties(Constant=true,Access=private)
        UNDEFINED_FUNCTION_EXCEPTION_ID='MATLAB:UndefinedFunction';
        UNDEFINED_VAR_OR_CLASS_EXCEPTION_ID='MATLAB:undefinedVarOrClass';

        EODATASTORE_FILE_PATH='EditorRunningFilePath';

        CurrentExecutionData=matlab.internal.editor.OutputUtilitiesDataHolder();
    end

    methods(Static,Hidden)

        function lineNumber=getLineNumberForExecutingFileFrame(stack,editorId)
            import matlab.internal.editor.EODataStore;
            import matlab.internal.editor.OutputUtilities;
            lineNumber=-1;



            if isempty(OutputUtilities.CurrentExecutionData.editorId)||...
                ~strcmp(OutputUtilities.CurrentExecutionData.editorId,editorId)
                OutputUtilities.CurrentExecutionData.set(editorId,...
                EODataStore.getEditorField(editorId,OutputUtilities.EODATASTORE_FILE_PATH));
            end




            filePath=OutputUtilities.CurrentExecutionData.filePath;
            filePathLength=length(filePath);
            startFrame=numel(stack);
            for i=startFrame:-1:1
                stackFrame=stack(i);
                stackFileLength=length(stackFrame.file);
                if(stackFileLength<filePathLength)
                    continue;
                end

                foundFile=strcmp(stackFrame.file,filePath);

                if(foundFile)
                    lineNumber=stackFrame.line;
                    return;
                end
            end
        end

        function checkForSuggestion=checkForSuggestions(exceptionId)


            import matlab.internal.editor.OutputUtilities

            checkForSuggestion=strcmp(exceptionId,OutputUtilities.UNDEFINED_FUNCTION_EXCEPTION_ID)||...
            strcmp(exceptionId,OutputUtilities.UNDEFINED_VAR_OR_CLASS_EXCEPTION_ID);
        end

        function clearCache()
            import matlab.internal.editor.OutputUtilities

            OutputUtilities.CurrentExecutionData.reset();
        end

    end
end