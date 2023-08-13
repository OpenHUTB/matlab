classdef EvaluateCodeException<matlab.internal.editor.EvaluatorException


    properties(Access=private)
Stack
LineNumber
Arg
    end

    methods
        function obj=EvaluateCodeException(sourceException,fileFullPath,tempFileFullPath)
            import matlab.internal.editor.EvaluateCodeException
            import matlab.internal.editor.EvaluatorException




            if isa(sourceException,'EvaluateCodeException')
                filePath=fileFullPath;
            else
                filePath=tempFileFullPath;
            end

            obj@matlab.internal.editor.EvaluatorException(sourceException,filePath,sourceException.getArgs());




            if isa(sourceException,'EvaluateCodeException')
                obj.Stack=sourceException.Stack;
                obj.message=sourceException.message;
                obj.type=sourceException.type;
                obj.LineNumber=sourceException.getLineNumber();
                obj.Arg=sourceException.getArgs();
                return;
            end

            obj.Stack=sourceException.getStack();


            obj.type=EvaluateCodeException.cleanType(...
            sourceException.type,...
            tempFileFullPath,...
            fileFullPath);




            obj.message=EvaluateCodeException.cleanTempFileFromMessage(...
            sourceException.message,...
            tempFileFullPath,...
            fileFullPath);
        end


    end

    methods(Access=protected)
        function stack=getStack(obj)





            stack=obj.Stack;
        end
    end

    methods(Static,Hidden)

        function cleanMessageText=cleanTempFileFromMessage(message,fullPathToReplace,fullPath)
            import matlab.internal.editor.EvaluatorException



            cleanMessageText=message;

            [~,tempFileName,tempFileExt]=fileparts(fullPathToReplace);
            [~,fileName,fileExt]=fileparts(fullPath);


            cleanMessageText=strrep(cleanMessageText,fullPathToReplace,fullPath);

            cleanMessageText=strrep(cleanMessageText,[tempFileName,tempFileExt],[fileName,fileExt]);

            cleanMessageText=strrep(cleanMessageText,tempFileName,fileName);
        end

        function cleanType=cleanType(type,fullPathToReplace,fullPath)
            [~,tempFileName,~]=fileparts(fullPathToReplace);
            [~,fileName,~]=fileparts(fullPath);

            cleanType=cell(size(type));

            for j=1:length(type)
                currentValue=type{j};
                if isstring(currentValue)||ischar(currentValue)
                    cleanType{j}=strrep(currentValue,tempFileName,fileName);
                else
                    cleanType{j}=currentValue;
                end
            end
        end
    end
end

