function[wasSuccess,editNamePayLoad]=updateSignalNames(inStruct)





    NUM_NAME_EDITS=length(inStruct);


    payLoadCell=cell(1,NUM_NAME_EDITS);
    wasSuccess=zeros(1,NUM_NAME_EDITS);


    for kEdit=1:NUM_NAME_EDITS

        appInstanceID=inStruct(kEdit).appInstanceID;
        baseMsg=inStruct(kEdit).baseMsg;
        sigID=inStruct(kEdit).sigID;
        sigFullName=inStruct(kEdit).sigFullName;
        newSignalName=inStruct(kEdit).newValue;
        namesCantBeUsed=inStruct(kEdit).namesCantBeUsed;
        shadowID=inStruct(kEdit).shadowID;

        if~isempty(shadowID)
            [wasSuccess(kEdit),payLoadCell{kEdit}]=Simulink.sta.signaltree.updateSignalName(appInstanceID,baseMsg,sigID,sigFullName,newSignalName,namesCantBeUsed,shadowID);
        else
            [wasSuccess(kEdit),payLoadCell{kEdit}]=Simulink.sta.signaltree.updateSignalName(appInstanceID,baseMsg,sigID,sigFullName,newSignalName,namesCantBeUsed);
        end
    end

    wasSuccess=all(wasSuccess);
    editNamePayLoad=[payLoadCell{:}];
