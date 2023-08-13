function jsonOutput=getOutputDataFromCaller(variableName)


    import matlab.internal.editor.OutputPackager
    import matlab.internal.editor.VariableOutputPackager


    jsonOutput="";
    if nargin~=1
        return
    end

    variableExistsInWorkspace=evalin('caller',['exist(''',variableName,''')']);

    if variableExistsInWorkspace~=1
        structOrObjectName=DataTipUtilities.getStructOrClassName(variableName);
        variableExistsInWorkspace=evalin('caller',['exist(''',structOrObjectName,''')']);

        if variableExistsInWorkspace~=1
            return;
        end

        [objectPart,methodOrProperty]=DataTipUtilities.getVariableNameParts(variableName);
        if evalin('caller',['ismethod(',objectPart,', ''',methodOrProperty,''')'])
            return;
        end
    end

    try
        variableValue=evalin('caller',variableName);

        if istall(variableValue)

            displayOfVariableValue=VariableOutputPackager.isolatedDisplaying(variableName,...
            variableValue);
            output=OutputPackager.getPackagedOutputForStdout(displayOfVariableValue);
        else
            output=OutputPackager.getPackagedOutputForVar(variableName,...
            variableValue);
        end

        jsonOutput=jsonencode(output);
    catch
        return;
    end
end