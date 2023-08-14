function removeSignal(this,sIndex)





    if length(sIndex)~=1
        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
    end

    if(sIndex<1)||(sIndex>this.nSignals)
        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
    end

    this.nSignals=this.nSignals-1;
    this.xcpSignals.removeAt(sIndex);
    this.signalStructs.removeAt(sIndex);

end
