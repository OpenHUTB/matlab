classdef EvaluatorException<MException


    properties(Access=private)
PrunedStack
LineNumber
TopSelfStackFrameLineNumber
Arg
    end

    properties(Constant=true,Access=private)


        LINE_NUMBER_REGEX='.+filename[^:]+:\s*(\d+)';
        FILE_NAME_PLACEHOLDER='filename';


        TEMP_FILE_REGEX='LiveEditorEvaluationHelperE.*?\.m';
    end

    methods
        function obj=EvaluatorException(mException,fileFullPath,arguments)
            import matlab.internal.editor.EvaluatorException



            try
                messageToUse=mException.message;
                identifierToUse=mException.identifier;
                typeToUse=mException.type;
            catch ME




                messageToUse=ME.message;
                identifierToUse='';
                typeToUse={2,''};
                arguments=[];
            end

            obj@MException(identifierToUse,'%s',messageToUse);

            obj.Arg=arguments;

            for i=1:length(mException.cause)
                obj=addCause(obj,mException.cause{i});
            end





            if length(typeToUse)>=2&&isequal(typeToUse{2},'builtin')
                obj.type={2,''};
            else
                obj.type=typeToUse;
            end




            if isa(mException,'EvaluatorException')


                obj.PrunedStack=mException.getStack();
                obj.LineNumber=mException.LineNumber;
                obj.type=typeToUse;
                obj.TopSelfStackFrameLineNumber=mException.getTopSelfStackFrameLineNumber();
            else

                obj.PrunedStack=obj.pruneStack(mException.getStack());




                obj.LineNumber=EvaluatorException.determineLineNumber(...
                obj.message,...
                obj.PrunedStack,...
                fileFullPath);
                obj.TopSelfStackFrameLineNumber=obj.determineTopSelfStackFrame(fileFullPath,obj.PrunedStack);

            end
        end

        function args=getArgs(obj)
            args=obj.Arg;
        end

        function lineNumber=getLineNumber(obj)
            lineNumber=obj.LineNumber;
        end

        function lineNumber=getTopSelfStackFrameLineNumber(obj)
            lineNumber=obj.TopSelfStackFrameLineNumber;
        end
    end

    methods(Access=protected)
        function stack=getStack(obj)






            stack=obj.PrunedStack;
        end
    end

    methods(Static,Hidden)
        function lineNumber=determineLineNumber(message,stack,fullPath)
            import matlab.internal.editor.DiagnosticOutputUtilities
            import matlab.internal.editor.EvaluatorException
            [~,fileName,fileExt]=fileparts(fullPath);
            fileNameWithExtension=[fileName,fileExt];

            lineNumber=DiagnosticOutputUtilities.getLineNumberFromStack(stack,fullPath);

            if lineNumber==-1



                lineNumber=EvaluatorException.getLineFromMessage(message,fileNameWithExtension);
            end
        end

        function messageLineNumber=getLineFromMessage(message,fileNameWithExtension)




            import matlab.internal.editor.EvaluatorException

            lineNumberRegex=strrep(...
            EvaluatorException.LINE_NUMBER_REGEX,...
            EvaluatorException.FILE_NAME_PLACEHOLDER,...
            fileNameWithExtension);
            rawLineNumber=regexp(message,lineNumberRegex,'tokens');

            if~isempty(rawLineNumber)
                messageLineNumber=str2double(rawLineNumber{1});
            else
                messageLineNumber=-1;
            end
        end
    end

    methods(Hidden)

        function prunedStack=pruneStack(obj,stack)




            import matlab.internal.editor.EvaluatorException


            if isempty(stack)
                prunedStack=[];
                return;
            end




            tempFileIndex=obj.findTempFileIndex(stack);
            if~isempty(tempFileIndex)
                prunedStack=stack(1:tempFileIndex);
            else




                prunedStack=matlab.internal.editor.StackPruner.getInstance().pruneStack(stack);
            end

        end

        function tempFileIndex=findTempFileIndex(obj,stack)


            import matlab.internal.editor.EvaluatorException

            tempFileIndex=[];
            startFrame=numel(stack);

            for i=startFrame:-1:1
                matchesTempFileRegex=~isempty(regexp(stack(i).file,EvaluatorException.TEMP_FILE_REGEX,'once'));
                if matchesTempFileRegex
                    tempFileIndex=i;
                    return;
                end
            end
        end

        function lineNumber=determineTopSelfStackFrame(obj,fullFile,stack)





            lineNumber=-1;
            stackLength=length(stack);



            for idx=stackLength:-1:1
                stackFullFile=stack(idx).file;
                if strcmp(fullFile,stackFullFile)


                    lineNumber=stack(idx).line;
                elseif(lineNumber>-1)


                    return;
                end
            end

            if lineNumber<0
                lineNumber=obj.LineNumber;
            end
        end
    end
end

