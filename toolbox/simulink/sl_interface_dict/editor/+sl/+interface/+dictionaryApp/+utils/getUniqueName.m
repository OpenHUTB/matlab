function uniqueName=getUniqueName(startName,protectedNames)

    if~ismember(startName,protectedNames)

        uniqueName=startName;
        return;
    end



    uniqueName=[message('interface_dictionary:common:CopyOf').getString(),...
    startName];

    if~ismember(uniqueName,protectedNames)
        return;
    end



    idx=2;
    uniqueName=startName;
    while ismember(uniqueName,protectedNames)
        uniqueName=[...
        message('interface_dictionary:common:CopyNumberOf',idx).getString(),...
        startName];
        idx=idx+1;
    end
end
