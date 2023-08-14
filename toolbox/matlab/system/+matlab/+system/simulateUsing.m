function simMode=simulateUsing(mode)












    ?matlab.system.SystemInterface;
    oldmode=feature('SystemObjectAccelerator');
    if nargin==0
        simMode=prepareOutput(oldmode);
        return;
    end

    if~(isstring(mode)||ischar(mode))
        error(message('MATLAB:system:Accelerator:simulateUsingInvalidValue',mode));
    end

    mode=convertStringsToChars(mode);
    isCodegen=strcmp(mode,'Code generation');
    isInterpreted=strcmp(mode,'Interpreted execution');
    isValueInvalid=~(isCodegen||isInterpreted);

    if any(isValueInvalid)
        error(message('MATLAB:system:Accelerator:simulateUsingInvalidValue',mode));
    end

    newMode=1;
    if isCodegen
        newMode=3;
    end

    if newMode~=oldmode
        feature('SystemObjectAccelerator',newMode);
    end
    simMode=prepareOutput(newMode);
end

function simMode=prepareOutput(mode)
    simMode='Interpreted execution';
    if(mode==3)
        simMode='Code generation';
    end
end
