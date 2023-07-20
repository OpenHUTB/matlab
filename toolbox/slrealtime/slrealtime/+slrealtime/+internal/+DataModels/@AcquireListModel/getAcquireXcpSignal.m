function[xcpSignals]=getAcquireXcpSignal(this,agi,signalIndex)





    if nargin<3,signalIndex=-1;end

    if signalIndex==-1
        xcpSignals=toArray(this.AcquireGroups(agi).xcpSignals);
    else
        xcpSignals=this.AcquireGroups(agi).xcpSignals(signalIndex);
    end
end
