function[hID,sID]=splitHarnessId(origId)

    colons=strfind(origId,':');
    if length(colons)==3

        hID=origId;
        sID='';
    else
        hID=origId(1:colons(4)-1);
        sID=origId(colons(4):end);
    end
end
