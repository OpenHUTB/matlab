function[newSignalID,parentID,jsonStruct,arrayOfProps]=pasteInputs(pasteStruct)




    SAME_MATLAB_SESSION=pasteStruct.copidSignalMatlabPid==pasteStruct.matlabPID;

    if SAME_MATLAB_SESSION
        [newSignalID,parentID,jsonStruct,arrayOfProps]=Simulink.sta.actions.pasteInput(pasteStruct);
    else

        newSignalID=[];
        parentID=[];
        jsonStruct=[];arrayOfProps=[];
    end
