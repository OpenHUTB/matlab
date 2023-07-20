





function groupSignalNamesUpdate(thisobj)

    sigNames={thisobj.Groups(end).Signals.Name};
    signalIdx=find(strcmp(sigNames,{thisobj.Groups(1).Signals.Name})==0);
    if~isempty(signalIdx)
        thisobj.groupSignalRename(signalIdx,sigNames(signalIdx),0);
    end
end