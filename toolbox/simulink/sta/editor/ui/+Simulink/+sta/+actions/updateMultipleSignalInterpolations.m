function[wasSuccess,editUnitPayLoad]=updateMultipleSignalInterpolations(inStruct)





    NUM_UNIT_EDITS=length(inStruct);


    payLoadCell=cell(1,NUM_UNIT_EDITS);
    wasSuccess=zeros(1,NUM_UNIT_EDITS);


    for kEdit=1:NUM_UNIT_EDITS

        appInstanceID=inStruct(kEdit).appInstanceID;
        baseMsg=inStruct(kEdit).baseMsg;
        sigID=inStruct(kEdit).sigID;
        newInterpVal=inStruct(kEdit).newValue;
        shadowID=inStruct(kEdit).shadowID;

        if~isempty(shadowID)
            [wasSuccess(kEdit),payLoadCell{kEdit}]=Simulink.sta.signaltree.updateSignalInterpolation(sigID,newInterpVal,baseMsg,appInstanceID);
        else
            [wasSuccess(kEdit),payLoadCell{kEdit}]=Simulink.sta.signaltree.updateSignalInterpolation(sigID,newInterpVal,baseMsg,appInstanceID,shadowID);
        end
    end

    wasSuccess=all(wasSuccess);
    editUnitPayLoad=[payLoadCell{:}];
