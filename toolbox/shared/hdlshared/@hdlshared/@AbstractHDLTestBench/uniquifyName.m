function newName=uniquifyName(~,signalName,signalNameSet)







    newName=signalName;
    newNameLower=lower(newName);
    ii=1;
    while(signalNameSet.isKey(newNameLower))
        newName=sprintf('%s_%d',signalName,ii);
        newNameLower=lower(newName);
        ii=ii+1;
    end
    signalNameSet(newNameLower)=true;%#ok<NASGU>