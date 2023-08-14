classdef ErrorRecoveryUtilities




    properties(Constant=true,Access=private)
        SUPRESS_OUTPUT_FEATURE_FLAG='SuppressCommandLineOutput';
    end

    methods(Static,Hidden)


        function processedEvaluatorException=startErrorRecovery(exception,code,exceptionLineNumber,fullFilePath)
            import matlab.internal.editor.EvaluatorException;
            import matlab.internal.editor.ErrorRecoveryUtilities;




            if exceptionLineNumber<=0
                lineOfCode="";
            else
                lineOfCode=ErrorRecoveryUtilities.extractLineOfCode(code,exceptionLineNumber);
            end

            [processedException,suggestion]=ErrorRecoveryUtilities.processException(exception,lineOfCode);
            processedEvaluatorException=EvaluatorException(processedException,fullFilePath,{suggestion});
        end
    end
    methods(Access=private,Static)

        function lineOfCode=extractLineOfCode(code,lineNumber)
            import matlab.internal.editor.CodeUtilities;

            numCharacters=CodeUtilities.findNumberOfCharactersToPriorToLine(code,lineNumber);
            if(CodeUtilities.numberOfLinesInText(code)==1)
                numCharactersUpper=numCharacters;
            else
                numCharactersUpper=CodeUtilities.findNumberOfCharactersToPriorToLine(code,lineNumber+1);
            end
            if numCharacters==numCharactersUpper
                lineOfCode=code(numCharacters+1:end);
            else


                lineOfCode=code(numCharacters+1:numCharactersUpper-1);
            end
        end


        function[processedException,suggestion]=processException(exception,lineOfCode)
            import matlab.internal.editor.ErrorRecoveryUtilities;


            priorState=feature(ErrorRecoveryUtilities.SUPRESS_OUTPUT_FEATURE_FLAG,true);

            cleanupObj=onCleanup(@()feature(ErrorRecoveryUtilities.SUPRESS_OUTPUT_FEATURE_FLAG,priorState));



            try
                [processedException,suggestion]=builtin("_InvokeErrorRecovery",exception,lineOfCode);
            catch
                processedException=exception;
                suggestion='';
            end
        end
    end
end
