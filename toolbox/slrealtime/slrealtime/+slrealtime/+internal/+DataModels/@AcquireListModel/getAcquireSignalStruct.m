function[signalStructs]=getAcquireSignalStruct(this,agi,signalIndex)





    if nargin<3,signalIndex=-1;end


    if signalIndex==-1
        signalStructs=toArray(this.AcquireGroups(agi).signalStructs);
    else
        signalStructs=this.AcquireGroups(agi).signalStructs(signalIndex);
    end

end
