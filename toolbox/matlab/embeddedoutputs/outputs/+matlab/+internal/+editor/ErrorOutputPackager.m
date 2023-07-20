classdef(Sealed,Hidden)ErrorOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)


        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,editorId,~,varargin)
            import matlab.internal.editor.EmbeddedOutputsException
            import matlab.internal.editor.OutputUtilities
            import matlab.internal.editor.DiagnosticOutputUtilities

            startExecutionLineNumber=varargin{1};
            filePath=varargin{2};


            exception=EmbeddedOutputsException(evalStruct.payload.exception,evalStruct.payload.fullFilePath,filePath);
            errText=getReport(exception);






            errText=DiagnosticOutputUtilities.cleanErrorText(errText,filePath,editorId);






            exceptionLineNumber=exception.getLineNumber();
            if exceptionLineNumber>0
                lineNumbers=exceptionLineNumber;
            elseif startExecutionLineNumber>0



                lineNumbers=startExecutionLineNumber;
            else



                lineNumbers=1;
            end




            sourceLineNumber=exception.getTopSelfStackFrameLineNumber();
            if sourceLineNumber==-1
                sourceLineNumber=lineNumbers;
            end



            exArguments=evalStruct.payload.exception.getArgs();
            if~isempty(exArguments)
                typoSuggestion=exArguments{1};
            else
                typoSuggestion='';
            end

            outputType='error';

            outputData.text=errText;
            outputData.errorType=char(evalStruct.payload.errorType);
            outputData.stackLineNumber=sourceLineNumber;
            outputData.identifier=typoSuggestion;
        end
    end
end
