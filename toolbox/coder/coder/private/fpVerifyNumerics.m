

function[messages,errorMessage,numericalErrors,reportFile]=fpVerifyNumerics(data,entryPoint,testFiles)
    manager=coder.internal.F2FGuiCallbackManager.getInstance();

    errorMessage='';%#ok<NASGU>
    messages=[];%#ok<NASGU>
    numericalErrors=[];%#ok<NASGU>
    try
        tbCount=length(testFiles);
        tbNames=cell(1,tbCount);
        for i=1:numel(testFiles)
            tbNames{i}=char(testFiles(i).getAbsolutePath());
        end
        [messages,errorMessage,numericalErrors,reportFile]=coderprivate.Float2FixedManager.instance.verifyNumerics(data,entryPoint,tbNames);

        manager.VerificationOutput{end+1}={messages,errorMessage,numericalErrors,reportFile};
    catch ex
        throwAsCaller(ex);
    end
end
