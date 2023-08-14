function[harnessId,localSid]=harnessTargetIdToSID(storedId)











    colsPos=find(storedId==':');
    if length(colsPos)<4
        harnessId=storedId(colsPos(1)+1:end);
        localSid='';
    else
        harnessId=storedId(colsPos(1)+1:colsPos(4)-1);
        localSid=storedId(colsPos(4):end);
    end
end
