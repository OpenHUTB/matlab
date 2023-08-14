function addCropOrExtractCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName)



    params=processData.Parameters;
    leftCursorPosition=params.cursorPositions.L;
    rightCursorPosition=params.cursorPositions.R;
    isTmModeSamples=this.TimeMode=="samples";
    preserveStartTime=params.preserveStartTime;

    if isTmModeSamples
        leftCursorPositionStr=string(ceil(leftCursorPosition)+1);
        rightCursorPositionStr=string(floor(rightCursorPosition)+1);
    else
        leftNprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(leftCursorPosition);
        rightNprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(rightCursorPosition);
        leftCursorPositionStr=num2str(leftCursorPosition,leftNprecision);
        rightCursorPositionStr=num2str(rightCursorPosition,rightNprecision);
    end

    if processData.ActionName=="crop"

        actionNameStr=getString(message('SDI:sigAnalyzer:crop'));
    else

        actionNameStr=getString(message('SDI:sigAnalyzer:extract'));
    end


    codeStr="% "+actionNameStr+newline;
    codeStr=codeStr+"timeLimits = ["+leftCursorPositionStr+" "+rightCursorPositionStr+"]; % ";

    if isTmModeSamples
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:samplesComment'));
    else
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:secondsComment'));
    end

    codeStr=codeStr+newline;


    if isTmModeSamples

        codeStr=codeStr+string(outputVarName)+" = "+string(inputVarName)+"(timeLimits(1):timeLimits(2));";
    else
        codeStr=codeStr+"keepIndices = ";
        codeStr=codeStr+inputTimeVarName;
        codeStr=codeStr+">=timeLimits(1) & ";
        codeStr=codeStr+inputTimeVarName;
        codeStr=codeStr+"<=timeLimits(2);"+newline;

        codeStr=codeStr+string(outputVarName)+" = "+string(inputVarName)+"(keepIndices);"+newline;

        codeStr=codeStr+string(outputTimeVarName)+" = "+...
        string(inputTimeVarName)+"(keepIndices);";
        if~preserveStartTime
            codeStr=codeStr+newline+string(outputTimeVarName)+" = "+...
            string(outputTimeVarName)+"-"+string(outputTimeVarName)+"(1); % "+...
            getString(message('signal_sigappsshared:preprocessingModeSA:moveInitialTimeToZeroComment'));
        end
    end

    codeBuffer.addcr('%s',codeStr);

end