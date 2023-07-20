function[loadFlag,registerNumberFlag]=ephLoadFlag(loadFlag,registerNumberFlag,registerNumber)
















    if isempty(loadFlag)
        loadFlag=true;
        registerNumberFlag=registerNumber;
    else
        if registerNumberFlag~=registerNumber
            loadFlag=true;
            registerNumberFlag=registerNumber;
        else
            loadFlag=false;
        end
    end
