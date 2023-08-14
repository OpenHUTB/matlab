function structure=utStruct(this)




    structure.Model=this.model_;
    structure.OverrideMode=double(this.overrideMode_);
    structure.LogAsSpecifiedByModels=...
    this.logAsSpecifiedByModels_;
    if isempty(structure.LogAsSpecifiedByModels),
        structure.LogAsSpecifiedByModels=cell(0,0);
    end
    nSignals=length(this.signals_);
    signals=cell(1,nSignals);
    for signalNo=1:nSignals,
        signals{signalNo}=...
        this.signals_(signalNo).utStructWithEscapeCharForBlockPath;
    end
    structure.Signals=signals;
end
