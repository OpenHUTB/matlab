function ts=getValuesForSignal(this,sig)






    if this.SignalValuesCache.isKey(sig.ID)
        ts=this.SignalValuesCache.getDataByKey(sig.ID);
        return
    end


    ts=sig.Values;
    if isa(ts,'timeseries')
        this.SignalValuesCache.insert(sig.ID,ts);
    end
end
