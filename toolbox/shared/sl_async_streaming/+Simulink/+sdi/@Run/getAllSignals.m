function signals=getAllSignals(this,varargin)




    ids=getAllSignalIDs(this,varargin{:});
    signals=Simulink.sdi.Signal.empty();
    for idx=1:numel(ids)
        signals(end+1)=Simulink.sdi.Signal(this.Repo,ids(idx));%#ok<AGROW>
    end
end
