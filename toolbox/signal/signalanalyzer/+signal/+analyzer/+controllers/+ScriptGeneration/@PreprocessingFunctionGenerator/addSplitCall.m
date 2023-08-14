function addSplitCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName)



    startTime=processData.Parameters.splitSegmentStartTime;
    endTime=processData.Parameters.splitSegmentEndTime;
    isFirstSplitSegment=processData.Parameters.isFirstSplitSegment;
    isLastSplitSegment=processData.Parameters.isLastSplitSegment;
    isTmModeSamples=this.TimeMode=="samples";
    preserveStartTime=processData.Parameters.preserveStartTime;

    if isTmModeSamples
        startTimeStr=string(floor(startTime)+1);
        endTimeStr=string(floor(endTime)+1);
    else
        startTimeNprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(startTime);
        endTimeNprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(endTime);
        startTimeStr=num2str(startTime,startTimeNprecision);
        endTimeStr=num2str(endTime,endTimeNprecision);
    end

    codeStr="% "+getString(message('SDI:sigAnalyzer:split'))+newline;



    if isFirstSplitSegment
        codeStr=codeStr+"splitTime = "+endTimeStr;
    elseif isLastSplitSegment
        codeStr=codeStr+"splitTime = "+startTimeStr;
    else
        codeStr=codeStr+"timeLimits = ["+startTimeStr+" "+endTimeStr+"]";
    end


    codeStr=codeStr+"; % ";

    if isTmModeSamples
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:samplesComment'));
    else
        codeStr=codeStr+getString(message('signal_sigappsshared:preprocessingModeSA:secondsComment'));
    end

    codeStr=codeStr+newline;


    if isTmModeSamples
        codeStr=codeStr+string(outputVarName)+" = "+string(inputVarName);

        if isFirstSplitSegment
            codeStr=codeStr+"(1:splitTime);";
        elseif isLastSplitSegment
            codeStr=codeStr+"(splitTime:end);";
        else
            codeStr=codeStr+"(timeLimits(1):timeLimits(2));";
        end
    else
        codeStr=codeStr+"keepIndices = ";
        codeStr=codeStr+inputTimeVarName;
        if isFirstSplitSegment
            codeStr=codeStr+"<=splitTime;";
        elseif isLastSplitSegment
            codeStr=codeStr+">splitTime;";
        else
            codeStr=codeStr+">timeLimits(1) & ";
            codeStr=codeStr+inputTimeVarName;
            codeStr=codeStr+"<=timeLimits(2);";
        end

        codeStr=codeStr+newline+string(outputVarName)+" = "+string(inputVarName)+"(keepIndices);"+newline;

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