function addTrimCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName)




    params=processData.Parameters;
    actionName=params.actionName;
    cursorPosition=params.cursorPositions.L;
    isTmModeSamples=this.TimeMode=="samples";
    isTrimLeft=actionName=="trimleft";
    isTrimRight=actionName=="trimright";
    preserveStartTime=params.preserveStartTime;

    if isTmModeSamples
        if isTrimLeft
            cursorPosition=ceil(cursorPosition);
        elseif isTrimRight
            cursorPosition=floor(cursorPosition);
        end
        cursorPositionStr=string(cursorPosition+1);
    else
        Nprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(cursorPosition);
        cursorPositionStr=num2str(cursorPosition,Nprecision);
    end

    codeStr="% ";

    if isTrimLeft
        codeStr=codeStr+getString(message('SDI:sigAnalyzer:trimleft'));
    elseif isTrimRight
        codeStr=codeStr+getString(message('SDI:sigAnalyzer:trimright'));
    end

    codeStr=codeStr+newline;

    codeStr=codeStr+"trimTime = "+cursorPositionStr+"; % ";

    if isTmModeSamples
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:samplesComment'));
    else
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:secondsComment'));
    end

    codeStr=codeStr+newline;

    if isTmModeSamples

        codeStr=codeStr+string(outputVarName)+" = "+string(inputVarName)+"(";
        if isTrimLeft
            codeStr=codeStr+"trimTime:end);";
        elseif isTrimRight
            codeStr=codeStr+"1:trimTime);";
        end
    else
        codeStr=codeStr+"keepIndices = "+inputTimeVarName;
        if isTrimLeft
            codeStr=codeStr+">=";
        elseif isTrimRight
            codeStr=codeStr+"<=";
        end

        codeStr=codeStr+"trimTime;"+newline;

        codeStr=codeStr+string(outputVarName)+" = "+...
        string(inputVarName)+"(keepIndices);"+newline;

        codeStr=codeStr+string(outputTimeVarName)+" = "+...
        string(inputTimeVarName)+"(keepIndices);";
        if isTrimLeft&&~preserveStartTime
            codeStr=codeStr+newline+string(outputTimeVarName)+" = "+...
            string(outputTimeVarName)+"-"+string(outputTimeVarName)+"(1); % "+...
            getString(message('signal_sigappsshared:preprocessingModeSA:moveInitialTimeToZeroComment'));
        end
    end

    codeBuffer.addcr('%s',codeStr);

end