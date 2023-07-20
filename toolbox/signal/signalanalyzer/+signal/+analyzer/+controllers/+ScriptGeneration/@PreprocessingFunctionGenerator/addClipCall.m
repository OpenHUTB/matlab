function addClipCall(~,codeBuffer,processData,inputVarName,outputVarName)




    params=processData.Parameters;
    actionName=params.actionName;
    cursorPosition=params.cursorPositions.T;
    isComplex=params.isComplex;
    isClipAbove=actionName=="clipabove";
    isClipBelow=actionName=="clipbelow";
    Nprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(cursorPosition);

    codeStr="% ";
    if isClipAbove
        codeStr=codeStr+getString(message('SDI:sigAnalyzer:clipabove'));
    elseif isClipBelow
        codeStr=codeStr+getString(message('SDI:sigAnalyzer:clipbelow'));
    end

    codeStr=codeStr+newline;

    codeStr=codeStr+"clipThreshold = "+num2str(cursorPosition,Nprecision)+";"+newline;

    if isComplex
        codeStr=codeStr+outputVarName+"_Real = real("+inputVarName+");"+newline;
        codeStr=codeStr+outputVarName+"_Imaginary = imag("+inputVarName+");"+newline;

        codeStr=codeStr+outputVarName+"_Real("+outputVarName+"_Real";
        if isClipAbove
            codeStr=codeStr+">";
        elseif isClipBelow
            codeStr=codeStr+"<";
        end
        codeStr=codeStr+"clipThreshold) = clipThreshold;"+newline;

        codeStr=codeStr+outputVarName+"_Imaginary("+outputVarName+"_Imaginary";
        if isClipAbove
            codeStr=codeStr+">";
        elseif isClipBelow
            codeStr=codeStr+"<";
        end
        codeStr=codeStr+"clipThreshold) = clipThreshold;"+newline;

        codeStr=codeStr+outputVarName+" = "+outputVarName+"_Real"+...
        " + 1i*"+outputVarName+"_Imaginary;";
    else
        if(string(inputVarName)~=outputVarName)
            codeStr=codeStr+outputVarName+" = "+inputVarName+";"+newline;
        end
        codeStr=codeStr+outputVarName+"("+outputVarName;

        if isClipAbove
            codeStr=codeStr+">";
        elseif isClipBelow
            codeStr=codeStr+"<";
        end

        codeStr=codeStr+"clipThreshold) = clipThreshold;";
    end
    codeBuffer.addcr('%s',codeStr);

end