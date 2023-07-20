function evaluateCode(fileName,filePath,...
    fullFileText,executionStartPosition,executionLength,...
    currentDocumentState,editorId,fileType,shouldThrowError,isSilent)



















    import matlab.internal.editor.eval.EvaluatorExceptionInfo
    import matlab.internal.editor.eval.EvaluationEndInfo
    import matlab.internal.editor.events.ErrorEventData
    import matlab.internal.editor.EvaluatorException
    import matlab.internal.editor.EvaluateCodeException
    import matlab.internal.editor.debug.DebugUtilities
    import matlab.internal.editor.ErrorType
    import matlab.internal.editor.DiagnosticOutputUtilities
    import matlab.internal.editor.StackPruner

    MAX_EVAL_TRIES=3;


    warningState=warning('query','backtrace');
    cleanupObj.warning=onCleanup(@()warning(warningState));
    warning backtrace off

    prelineState=feature('DisablePrelineEvents',true);
    cleanupObj.preline=onCleanup(@()feature('DisablePrelineEvents',prelineState));

    if nargin<10
        isSilent=false;
    end

    if nargin<9
        shouldThrowError=false;
    end

    if nargin<8||isempty(fileType)
        tree=mtree(fullFileText);
        fileType=char(tree.FileType);
    end


    if~isSilent
        message.publish(['/execution/startingEvaluation/',editorId],[]);
    end


    if usejava('jvm')
        com.mathworks.mde.embeddedoutputs.RegionEvaluator.markEditorAsExecuting();
        cleanupObj.status=onCleanup(@()com.mathworks.mde.embeddedoutputs.RegionEvaluator.markEditorAsDoneExecuting());
    end






    evaluationEndInfo=EvaluationEndInfo(false,ErrorType.None,0);
    if~isSilent
        cleanupObj.evalEnd=onCleanup(@()publishEvalCompleteMessage(evaluationEndInfo,editorId));
    end


    forceBreakpointsOn=~system_dependent('IsDebugMode');


    fullFileText=regexprep(fullFileText,sprintf('(\r\n)|\r|\n'),char(10));%#ok<CHARTEN>

    StackPruner.getInstance().setBase(dbstack("-completenames"));
    cleanupObj.clearPruningBase=onCleanup(@()StackPruner.getInstance().clear());



    if strcmp(fileType,'ClassDefinitionFile')
        matlab.internal.editor.debug.DebugUtilities.getInstance.enableStackPruning();

        evalText=fullFileText(executionStartPosition:(executionStartPosition+executionLength-1));


        debuggerCleanup=[];%#ok<*NASGU>
        if forceBreakpointsOn
            originalValue=builtin('_changeDebuggerEnablement',true);
            debuggerCleanup=onCleanup(@()builtin('_changeDebuggerEnablement',originalValue));
        end

        try
            evalin('caller',evalText);
        catch ME
            if shouldThrowError
                ME.rethrow;
            end
            if isa(ME,'matlab.exception.JavaException')&&isa(ME.ExceptionObject,'java.lang.OutOfMemoryException')
                ME.rethrow;
            end

            ME=matlab.internal.editor.ErrorRecoveryUtilities.startErrorRecovery(ME,fullFileText,-1,filePath);


            errorListener(ErrorEventData(ME,[],''),'',editorId);
        end

        debuggerCleanup=[];
        return;
    end

    scriptFile=builtin('_WriteTempFileForEval',editorId,fullFileText,currentDocumentState,false);
    [~,scriptName,~]=fileparts(scriptFile);

    originalFullFilePath=fullfile(filePath,fileName);
    if forceBreakpointsOn
        cleanupObj.debugging=DebugUtilities.enableDebuggingSupport(scriptFile,originalFullFilePath);
    end


    if executionLength~=0

        convertedStartPos=builtin('_convertExecutionBounds',fullFileText(1:executionStartPosition-1))+1;

        executionLength=builtin('_convertExecutionBounds',fullFileText(executionStartPosition:(executionStartPosition+executionLength-1)));
        executionStartPosition=convertedStartPos;
    end

    exceptionInfo=[];



    for i=1:MAX_EVAL_TRIES
        try
            evaluationEndInfo.DidRunToCompletion=false;
            evaluationEndInfo.setError(ErrorType.None,0);
            try
                builtin('_LiveEvaluate','caller',scriptName,executionStartPosition,executionLength,[],[],[],[],forceBreakpointsOn,fullFileText);
                evaluationEndInfo.DidRunToCompletion=true;
                evaluationEndInfo.setError(ErrorType.None,0);
            catch aException
                exceptionInfo=EvaluatorExceptionInfo(aException,scriptName);



                if exceptionInfo.shouldIgnoreError()
                    evaluationEndInfo.DidRunToCompletion=true;
                    evaluationEndInfo.setError(ErrorType.None,0);

                elseif exceptionInfo.isUnfoundFile()


                    aException.rethrow();
                else


                    aException=EvaluatorException(aException,originalFullFilePath,aException.arguments);


                    errorLine=aException.getTopSelfStackFrameLineNumber();
                    aException=matlab.internal.editor.ErrorRecoveryUtilities.startErrorRecovery(aException,fullFileText,errorLine,filePath);

                    aException=EvaluateCodeException(aException,originalFullFilePath,scriptFile);

                    isSyntaxError=exceptionInfo.isSyntaxError();
                    if(isSyntaxError)
                        errorType=ErrorType.Syntax;
                    else
                        errorType=ErrorType.Runtime;
                    end

                    evaluationEndInfo.DidRunToCompletion=false;
                    evaluationEndInfo.setError(errorType,errorLine);


                    if shouldThrowError
                        throwAsCaller(aException)
                    else

                        errorListener(ErrorEventData(aException,[],scriptFile),originalFullFilePath,editorId);
                    end
                end
            end

            break;
        catch e



            if shouldThrowError&&(isempty(exceptionInfo)||~exceptionInfo.isUnfoundFile())
                throwAsCaller(aException);
            end

            if i==MAX_EVAL_TRIES

                e.rethrow();
            else

                scriptFile=builtin('_WriteTempFileForEval',editorId,fullFileText,currentDocumentState,true);
            end
        end
    end
end

function errorListener(eventData,filePath,editorId)
    message=getReport(eventData.Exception);
    message=matlab.internal.editor.DiagnosticOutputUtilities.cleanErrorText(message,filePath,editorId);





    message=strrep(message,'\','\\');
    message=strrep(message,'%','%%');

    beep;

    disp('');

    message=evalc('matlab.internal.display.printWrapped(message)');
    fprintf(2,[message,10]);
end

function publishEvalCompleteMessage(evaluationEndInfo,editorId)
    [msg,msgID]=lastwarn;
    message.publish(['/traditionalexecution/evaluatecode/response_',editorId],evaluationEndInfo)
    message.publish(['/execution/endingEvaluation/',editorId],[]);


    lastwarn(msg,msgID);
end
