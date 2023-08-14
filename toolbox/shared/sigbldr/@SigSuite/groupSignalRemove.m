





function groupSignalRemove(this,removeSignals)
    removeSignals=groupSignalIndexCheck(this,removeSignals,[],'S');
    for m=1:this.NumGroups

        this.Groups(m).signalRemove(removeSignals);
    end
end